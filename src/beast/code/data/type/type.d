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
import beast.backend.common.primitiveop;
import beast.code.data.util.btsp;
import beast.code.data.var.btspconst;
import beast.corelib.type.reference : Symbol_Type_Reference;
import beast.corelib.type.int_;
import beast.code.data.function_.primstcnrt;
import beast.code.ast.expr.expression;

__gshared UIDKeeper!Symbol_Type typeUIDKeeper;
private enum _init = HookAppInit.hook!( { typeUIDKeeper.initialize( ); } );

/// Type in the Beast language
abstract class Symbol_Type : Symbol {
	mixin TaskGuard!"instanceSizeLiteralObtaining";

	public:
		this( ) {
			typeUID_ = typeUIDKeeper( this );

			with ( memoryManager.session( SessionPolicy.doNotWatchCtChanges ) ) {
				MemoryBlock block = memoryManager.allocBlock( UIDGenerator.I.sizeof, MemoryBlock.Flag.ctime );
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
			mem ~= new Symbol_BootstrapStaticNonRuntimeFunction( dataEntity, ID!"#opSuffix", //
					Symbol_BootstrapStaticNonRuntimeFunction.paramsBuilder( ).constArg( coreEnum.operator.suffRef ).finish( ( AST_Node ast ) { //
						return coreType.Reference.referenceTypeOf( this ).dataEntity; //
					} ), //
					true );

			// T! -> T (for now - future: mutable)
			mem ~= new Symbol_BootstrapStaticNonRuntimeFunction( dataEntity, ID!"#opSuffix", //
					Symbol_BootstrapStaticNonRuntimeFunction.paramsBuilder( ).constArg( coreEnum.operator.suffNot ).finish( ( AST_Node ast ) { //
						return this.dataEntity; //
					} ), //
					true );

			// Implicit cast to reference
			if ( !isReferenceType ) {
				auto refType = coreType.Reference.referenceTypeOf( this );
				// Implicit cast to reference type
				mem ~= new Symbol_PrimitiveMemberRuntimeFunction( ID!"#implicitCast", this, refType, //
						ExpandedFunctionParameter.bootstrap( refType.dataEntity ), //
						( cb, inst, args ) { //
							auto var = new DataEntity_TmpLocalVariable( refType );
							cb.build_localVariableDefinition( var );
							cb.build_primitiveOperation( BackendPrimitiveOperation.markPtr, var );
							cb.build_primitiveOperation( BackendPrimitiveOperation.getAddr, var, inst );

							// Result
							var.buildCode( cb );
						} );
			}

			// #call( ) -> ctor
			mem ~= new Symbol_BootstrapStaticNonRuntimeFunction( dataEntity, ID!"#call", //
					// TODO: Accept additional arguments (pass them to cast functions)
					Symbol_BootstrapStaticNonRuntimeFunction.paramsBuilder( ).ast( ).finish(  //
						( AST_Node nd, AST_Expression[ ] asts, DataEntity[ ] entities ) { //
						return cast( DataEntity ) new DataEntity_Bootstrap( ID!"#call", this, this.dataEntity, false, ( cb ) { //
							auto var = new DataEntity_TmpLocalVariable( this );
							cb.build_localVariableDefinition( var );

							auto match = var.dataType.expectResolveIdentifier_direct( ID!"#ctor", var, MatchLevel.fullMatch ).CallMatchSet( ast, true, MatchLevel.fullMatch );
							foreach ( i, ent; entities ) {
								if ( ent )
									match.arg( ent );
								else
									match.arg( asts[ i ] );
							}
							match.finish.buildCode( cb );

							var.buildCode( cb );
						} );
					} //
					 ), true );

			// .to( XX )
			mem ~= new Symbol_PrimitiveMemberNonRuntimeFunction( ID!"to", this, //
					// TODO: Accept additional arguments (pass them to cast functions)
					Symbol_PrimitiveMemberNonRuntimeFunction.paramsBuilder( ).ctArg( coreType.Type ).finish(  //
						( AST_Node ast, DataEntity inst, MemoryPtr targetType ) { //
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

			// .#addr
			// TODO: better?
			mem ~= new Symbol_BootstrapAlias( ID!"#addr", //
					( MatchLevel matchLevel, DataEntity inst ) => new DataEntity_Bootstrap( ID!"addr", coreType.Pointer, inst ? inst : dataEntity, inst ? inst.isCtime : true, //
						( CodeBuilder cb ) { //
							benforce( inst !is null, E.needThis, "Need this for %s.#addr".format( dataEntity.identificationString ) );

							auto var = new DataEntity_TmpLocalVariable( coreType.Pointer );
							cb.build_localVariableDefinition( var );
							cb.build_primitiveOperation( BackendPrimitiveOperation.markPtr, var );
							cb.build_primitiveOperation( BackendPrimitiveOperation.getAddr, var, inst );

							// Reulst
							var.buildCode( cb );
						} ).Overloadset );

			// #instanceSize, lazily initialized
			mem ~= new Symbol_BootstrapAlias( ID!"#instanceSize", ( matchLevel, inst ) => instanceSizeLiteral.Overloadset );

			// T1 == T2 type compare
			mem ~= new Symbol_BootstrapStaticNonRuntimeFunction( dataEntity, ID!"#opBinary", //
					Symbol_BootstrapStaticNonRuntimeFunction.paramsBuilder( ).constArg( coreEnum.operator.binEq ).ctArg( coreType.Type ).finish( ( ast, arg ) { //
						return ( arg.readType is this ) ? coreConst.true_.dataEntity : coreConst.false_.dataEntity;
					} ), //
					true );

			// T1 != T2 type compare
			mem ~= new Symbol_BootstrapStaticNonRuntimeFunction( dataEntity, ID!"#opBinary", //
					Symbol_BootstrapStaticNonRuntimeFunction.paramsBuilder( ).constArg( coreEnum.operator.binNeq ).ctArg( coreType.Type ).finish( ( ast, arg ) { //
						return ( arg.readType is this ) ? coreConst.false_.dataEntity : coreConst.true_.dataEntity;
					} ), //
					true );

			baseNamespace_.initialize( mem );

			debug initialized_ = true;
		}

		/// Each type has uniquie UID in the project (differs each compiler run)
		final UIDGenerator.I typeUID( ) {
			return typeUID_;
		}

		/// Size of instance in bytes
		abstract size_t instanceSize( );

		/// Size of instance as literal constant
		final DataEntity instanceSizeLiteral( ) {
			enforceDone_instanceSizeLiteralObtaining( );
			return instanceSizeLiteralWIP_;
		}

	public:
		final Overloadset tryResolveIdentifier( Identifier id, DataEntity instance, MatchLevel matchLevel = MatchLevel.fullMatch ) {
			debug assert( initialized_, "Class '%s' not initialized".format( this.tryGetIdentificationString ) );

			if ( auto result = _resolveIdentifier_pre( id, instance, matchLevel ) )
				return result;

			if ( auto result = tryResolveIdentifier_direct( id, instance, matchLevel ) )
				return result;

			if ( auto result = _resolveIdentifier_mid( id, instance, matchLevel ) )
				return result;

			return Overloadset( );
		}

		/// Resolves the identifier, but doesn't look into aliases n' stuff. Used for calling constructors and destructors
		final Overloadset tryResolveIdentifier_direct( Identifier id, DataEntity instance, MatchLevel matchLevel = MatchLevel.fullMatch ) {
			debug assert( initialized_, "Class '%s' not initialized".format( this.tryGetIdentificationString ) );

			import std.array : appender;

			auto result = appender!( DataEntity[ ] );

			// baseNamespace_ contains auto-generated members like operator T?, #instanceSize etc
			result ~= baseNamespace_.tryResolveIdentifier( id, instance, matchLevel );

			// Add direct members to the overloadset
			result ~= namespace.tryResolveIdentifier( id, instance, matchLevel );

			return Overloadset( result.data );
		}

		final Overloadset expectResolveIdentifier( Identifier id, DataEntity instance, MatchLevel matchLevel = MatchLevel.fullMatch ) {
			if ( auto result = tryResolveIdentifier( id, instance, matchLevel ) )
				return result;

			berror( E.unknownIdentifier, "Could not resolve identifier '%s' for %s".format( id.str, identificationString ) );
			assert( 0 );
		}

		final Overloadset expectResolveIdentifier_direct( Identifier id, DataEntity instance, MatchLevel matchLevel = MatchLevel.fullMatch ) {
			if ( auto result = tryResolveIdentifier_direct( id, instance, matchLevel ) )
				return result;

			berror( E.unknownIdentifier, "Could not resolve identifier '%s' for %s".format( id.str, identificationString ) );
			assert( 0 );
		}

		/// Returns string representing given value of given type (for example bool -> true/false)
		string valueIdentificationString( MemoryPtr value ) {
			return "%s( ... )".format( identification );
		}

	public:
		/// Returns if the type is reference type (X?)
		Symbol_Type_Reference isReferenceType( ) {
			return null;
		}

		Symbol_Type_Int isIntType( ) {
			return null;
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
		void execute_instanceSizeLiteralObtaining( ) {
			instanceSizeLiteralWIP_ = new Symbol_BootstrapConstant( this.dataEntity, ID!"#instanceSize", coreType.Size, instanceSize ).dataEntity;
		}

	private:
		MemoryPtr ctimeValue_;
		/// Namespace containing implicit/default types for a type (implicit operators, reflection functions etc)
		BootstrapNamespace baseNamespace_;
		UIDGenerator.I typeUID_;
		DataEntity instanceSizeLiteralWIP_;

	protected:
		abstract static class Data : SymbolRelatedDataEntity {

			public:
				this( Symbol_Type sym, MatchLevel matchLevel ) {
					super( sym, matchLevel );

					sym_ = sym;
				}

			public:
				override Symbol_Type dataType( ) {
					return coreType.Type;
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
