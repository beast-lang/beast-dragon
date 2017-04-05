module beast.code.data.type.type;

import beast.code.data.alias_.btsp;
import beast.code.data.codenamespace.bootstrap;
import beast.code.data.codenamespace.namespace;
import beast.code.data.function_.bstpstcnrt;
import beast.code.data.function_.expandedparameter;
import beast.code.data.function_.primmemnrt;
import beast.code.data.function_.primmemrt;
import beast.code.data.toolkit;
import beast.code.data.var.tmplocal;
import beast.code.hwenv.hwenv;
import beast.toolkit;
import beast.util.uidgen;
import core.stdc.string : memcpy;
import std.range : chain;
import beast.code.data.var.literal;

__gshared UIDKeeper!Symbol_Type typeUIDKeeper;
private enum _init = HookAppInit.hook!( { typeUIDKeeper.initialize( ); } );

/// Type in the Beast language
abstract class Symbol_Type : Symbol {

	public:
		this( ) {
			typeUID_ = typeUIDKeeper( this );

			with ( memoryManager.session ) {
				MemoryBlock block = memoryManager.allocBlock( size_t.sizeof );
				block.identifier = "%s_typeid".format( identifier.str );
				block.markDoNotGCAtSessionEnd( );
				ctimeValue_ = block.startPtr.writePrimitive( typeUID_ );
			}

			baseNamespace_ = new BootstrapNamespace( this );

			taskManager.delayedIssueJob( { project.backend.buildType( this ); } );
		}

		void initialize( ) {
			Symbol[ ] mem;

			// T? -> reference
			mem ~= new Symbol_BootstrapStaticNonRuntimeFunction( dataEntity, ID!"#opUnary", //
					Symbol_BootstrapStaticNonRuntimeFunction.paramsBuilder( ).constArg( coreLibrary.enum_.operator.suffRef ).finish( ( ast ) { //
						return coreLibrary.type.Reference.referenceTypeOf( this ).dataEntity; //
					} ), //
					true );

			// Implicit cast to reference
			if ( !isReferenceType ) {
				auto refType = coreLibrary.type.Reference.referenceTypeOf( this );
				// Implicit cast to reference type
				mem ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#implicitCast", this, refType, //
						ExpandedFunctionParameter.bootstrap( refType.dataEntity ), //
						( cb, inst, args ) { //
							auto var = new DataEntity_TmpLocalVariable( refType, cb.isCtime );
							cb.build_localVariableDefinition( var );
							var.expectResolveIdentifier( ID!"#ctor" ).resolveCall( null, true, coreLibrary.enum_.xxctor.refAssign.dataEntity, inst ).buildCode( cb );
							var.buildCode( cb );
						} );
			}

			// to function
			mem ~= new Symbol_PrimitiveMemberNonRuntimeFunction( ID!"to", this, //
					Symbol_PrimitiveMemberNonRuntimeFunction.paramsBuilder( ).ctArg( coreType.Type ).finish(  //
						( AST_Node, DataEntity inst, MemoryPtr targetType ) { //
						DataEntity targetTypeEntity = targetType.readType.dataEntity;

						CallMatchSet explicitCast = inst.tryResolveIdentifier( ID!"#explicitCast" ).CallMatchSet( ast, false ).arg( targetTypeEntity );
						if ( auto result = explicitCast.finish( ) )
							return result;

						CallMatchSet implicitCast = inst.tryResolveIdentifier( ID!"#implicitCast" ).CallMatchSet( ast, false ).arg( targetTypeEntity );
						if ( auto result = implicitCast.finish( ) )
							return result;

						berror( E.cannotResolve, "Cannot resolve %s.to( %s ):%s".format(  //
						inst.identificationString, targetTypeEntity.identificationString, //
						chain( explicitCast.matches, implicitCast.matches ).map!( x => "\n\t%s:\n\t\t%s\n".format( x.sourceDataEntity.identificationString, x.errorStr ) ).joiner //
						 ) );
						assert( 0 );
					} //
					 ) );

			// #instanceSize
			// TODO: BETTER
			mem ~= new Symbol_BootstrapAlias( ID!"#instanceSize", //
					( MatchLevel matchLevel, DataEntity inst ) { //
						ubyte[ ] data;
						data.length = hardwareEnvironment.pointerSize;

						size_t instanceSize = instanceSize;
						memcpy( data.ptr, &instanceSize, hardwareEnvironment.effectivePointerSize );

						return new Symbol_Literal( coreType.Size, data ).dataEntity.Overloadset;
					} );

			baseNamespace_.initialize( mem );

			debug initialized_ = true;
		}

		/// Each type has uniquie UID in the project (differs each compiler run)
		final size_t typeUID( ) {
			return typeUID_;
		}

		/// Size of instance in bytes
		abstract size_t instanceSize( );

	public:
		final Overloadset resolveIdentifier( Identifier id, DataEntity instance, MatchLevel matchLevel = MatchLevel.fullMatch ) {
			debug assert( initialized_, "Class '%s' not initialized".format( this.tryGetIdentificationString ) );
			/*import std.stdio;

			writefln( "Resolve %s for %s ( entity %s of type %s )", id.str, identificationString, instance ? instance.identificationString : "#", instance ? instance.dataType.identificationString : "#" );*/

			if ( auto result = _resolveIdentifier_pre( id, instance, matchLevel ) )
				return result;

			import std.array : appender;

			{
				auto result = appender!( DataEntity[ ] );

				// baseNamespace_ contains auto-generated members like operator T?, #instanceSize etc
				result ~= baseNamespace_.resolveIdentifier( id, instance, matchLevel );

				// Add direct members to the overloadset
				result ~= namespace.resolveIdentifier( id, instance, matchLevel );

				if ( result.data )
					return Overloadset( result.data );
			}

			if ( auto result = _resolveIdentifier_mid( id, instance, matchLevel ) )
				return result;

			// If this ever needs to be enabled, the reference #opXX fallback function needs to be reworked
			// (as it would not pass anything to this)
			// Look in the core.Type
			/*if ( this !is coreLibrary.type.Type ) {
				// We don't pass an instance to this because that would cause loop
				if ( auto result = coreLibrary.type.Type.resolveIdentifier( id, null ) )
					return result;
			}*/

			return Overloadset( );
		}

		/// Returns string representing given value of given type (for example bool -> true/false)
		string valueIdentificationString( MemoryPtr value ) {
			return "%s( ... )".format( identification );
		}

	public:
		/// Returns if the type is reference type (X?)
		bool isReferenceType( ) {
			return false;
		}

	protected:
		/// Namespace with members of this type (static and dynamic)
		abstract Namespace namespace( );

	protected:
		Overloadset _resolveIdentifier_pre( Identifier id, DataEntity instance, MatchLevel matchLevel = MatchLevel.fullMatch ) {
			return Overloadset( );
		}

		Overloadset _resolveIdentifier_mid( Identifier id, DataEntity instance, MatchLevel matchLevel = MatchLevel.fullMatch ) {
			return Overloadset( );
		}

	protected:
		debug bool initialized_;

	private:
		MemoryPtr ctimeValue_;
		/// Namespace containing implicit/default types for a type (implicit operators, reflection functions etc)
		BootstrapNamespace baseNamespace_;
		size_t typeUID_;

	protected:
		abstract static class Data : SymbolRelatedDataEntity {

			public:
				this( Symbol_Type sym, MatchLevel matchLevel ) {
					super( sym, matchLevel );

					sym_ = sym;
				}

			public:
				override Symbol_Type dataType( ) {
					return coreLibrary.type.Type;
				}

				override bool isCtime( ) {
					return true;
				}

			public:
				final override void buildCode( CodeBuilder cb ) {
					auto _gd = ErrorGuard( this );

					cb.build_memoryAccess( sym_.ctimeValue_ );
				}

			private:
				Symbol_Type sym_;

		}

}
