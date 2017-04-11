module beast.code.data.entity;

import beast.code.data.toolkit;
import beast.util.identifiable;
import beast.code.data.decorator.decorator;
import beast.core.project.codelocation;
import beast.code.data.callable.match;
import beast.code.data.type.type;
import beast.code.data.util.reinterpret;
import beast.code.data.util.deref;

/// DataEntity stores information about a value: what is its type and how to obtain it (how to build code that obtains it)
/// It is practically a semantic tree node
abstract class DataEntity : Identifiable {

	public:
		this( MatchLevel matchLevel ) {
			overloadMatch_ = matchLevel;
		}

	public:
		/// Type of the data; can be null (mostly when reflection is not implemented)
		abstract Symbol_Type dataType( );

		/// Parent of the current data entity, is used in recursive identifier resolution
		abstract DataEntity parent( );

		/// Symbol if we call .dataEntity on returns this DataEntity (or same type)
		Symbol symbol( ) {
			return null;
		}

		/// Specifies priority of this entity among overloading
		final MatchLevel matchLevel( ) {
			return overloadMatch_;
		}

		/// If the data is known at compile time
		/// This can be false even if the entity is inferable at compile time (for example function calls)
		/// This is mostly used in operator overloading (ctime vs nonctime overloads)
		abstract bool isCtime( );

		Symbol_Decorator isDecorator( ) {
			return null;
		}

		/// If the data entity represents a parameter, returns its index
		size_t asFunctionParameter_index( ) {
			assert( 0, identificationString ~ " is not a parameter" );
		}

		/// If the data entity represents a local variable, returns its base pointer offset for interpreter
		size_t asLocalVariable_interpreterBpOffset( ) {
			assert( 0, identificationString ~ " is not a local variable" );
		}

	public:
		/// Identifier of the data that vaguely corresponds with the symbol table (can be null)
		Identifier identifier( ) {
			return null;
		}

		/// Identification of the entity for error printing purposes
		string identification( ) {
			if ( auto id = identifier )
				return id.str;

			return "#tmp#";
		}

		/// Full identification string of the entity (with prefix)
		string identificationString( ) {
			return identificationString_noPrefix( );
		}

		// This gets kinda messy, I know
		string identificationString_noPrefix( ) {
			if ( auto parentIdentificationString = parent.tryGetIdentificationString_noPrefix )
				return "%s.%s".format( parentIdentificationString, this.tryGetIdentification );
			else
				return this.tryGetIdentification;
		}

		/// Executes the dataEntity at ctime and returns string describing its value
		pragma( inline ) final string valueIdentificationString( ) {
			return dataType.valueIdentificationString( ctExec( ) );
		}

		/// AST node related with the entity, can be null
		abstract AST_Node ast( );

		/// Location in the code related to the data entity
		final CodeLocation codeLocation( ) {
			return ast ? ast.codeLocation : cast( CodeLocation ) null;
		}

		/// Outer hash - hash that is generated based on entity declaration and surroundings, not its definition (considering classes, functions, etc)
		Hash outerHash( ) {
			return parent.outerHash;
		}

	public:
		/// Returns if the current entity is callable
		bool isCallable( ) {
			return false;
		}

		/// Creates a class instance that is in charge of matching the currect callable entity with an argument list
		CallableMatch startCallMatch( AST_Node ast, bool canThrowErrors, MatchLevel matchLevel ) {
			assert( 0, identificationString ~ " is not callable" );
		}

		/// Resolves call with given arguments (can either be AST_Expression or DataEntity or ranges of both)
		final DataEntity resolveCall( Args... )( AST_Node ast, bool reportErrors, Args args ) {
			auto _gd = ErrorGuard( ast );

			CallableMatch match = startCallMatch( ast, reportErrors, overloadMatch_ );

			foreach ( arg; args )
				match.arg( arg );

			match.finish( );

			benforce( match.matchLevel != MatchLevel.noMatch, E.noMatchingOverload, "%s does not match given arguments: %s".format( identificationString, match.errorStr ) );

			return match.toDataEntity( );
		}

	public:
		/// Resolves identifier (drill-down)
		/// The scope can be used for creating temporary variables
		/// Can return empty overloadset
		final Overloadset tryResolveIdentifier( Identifier id, MatchLevel matchLevel = MatchLevel.fullMatch ) {
			if ( id == ID!"#type" )
				return Overloadset( dataType.dataEntity );

			if ( auto result = _resolveIdentifier_pre( id, matchLevel ) )
				return result;

			if ( auto result = _resolveIdentifier_main( id, matchLevel ) )
				return result;

			if ( auto result = dataType.resolveIdentifier( id, this, matchLevel ) )
				return result;

			return Overloadset( );
		}

		/// Resolves the identifier, throws an error if the overloadset is empty
		final Overloadset expectResolveIdentifier( Identifier id, MatchLevel matchLevel = MatchLevel.fullMatch ) {
			auto result = tryResolveIdentifier( id, matchLevel );
			benforce( !result.isEmpty, E.unknownIdentifier, "Could not resolve identifier '%s' for %s".format( id.str, identificationString ) );
			return result;
		}

		/// Resolves identifier recursively (looking into parent entities)
		/// The scope can be used for creating temporary variables
		final Overloadset recursivelyResolveIdentifier( Identifier id, MatchLevel matchLevel = MatchLevel.fullMatch ) {
			if ( auto result = tryResolveIdentifier( id, matchLevel ) )
				return result;

			if ( auto parent = parent ) {
				if ( auto result = parent.recursivelyResolveIdentifier( id, matchLevel ) )
					return result;
			}

			return Overloadset( );
		}

	public:
		/// Enforces that the resulting entity is of dataType targetType (either returns itself or creates a cast call)
		final DataEntity enforceCast( Symbol_Type targetType ) {
			if ( dataType == targetType )
				return this;

			DataEntity result = tryCast( targetType );
			benforce( result !is null, E.notImplemented, "Casting is not implemented yet" );

			return result;
		}

		/// Tries to cast to the targetType (or returns itself if already is of targe type). Returns null on failure
		final DataEntity tryCast( Symbol_Type targetType ) {
			if ( dataType is targetType )
				return this;

			if ( auto castCall = tryResolveIdentifier( ID!"#implicitCast" ).resolveCall( ast, false, targetType.dataEntity ) ) {
				benforce( castCall.dataType is targetType, E.invalidCastReturnType, "%s has return type %s (#cast always have to return type given by first parameter)".format( castCall.identificationString, castCall.dataType.identificationString ) );
				return castCall;
			}

			/// TODO: Implicit cast check
			/// TODO: alias this check
			return null;
		}

		/// Returns data entity representing this data entity reintrerpreted as targetType
		pragma( inline ) final DataEntity reinterpret( Symbol_Type targetType ) {
			return new DataEntity_ReinterpretCast( this, targetType );
		}

		/// Returns data entity representing data entity referenced by the current one (it is assumed that current data entity is of reference type)
		pragma( inline ) final DataEntity dereference( Symbol_Type targetType ) {
			return new DataEntity_DereferenceProxy( this, targetType );
		}

	public:
		/// Builds code that matches the semantic tree (scope is used for variable allocations)
		void buildCode( CodeBuilder cb ) {
			assert( 0, "buildCode not implemented for " ~ identificationString );
		}

	public:
		/// Executes the expression in standalone scope and session, returing its value
		final MemoryPtr ctExec( ) {
			with ( memoryManager.session ) {
				scope cb = new CodeBuilder_Ctime;
				buildCode( cb );
				return cb.result;
			}
		}

		/// Expects the data to point at Type instance
		final Symbol_Type ctExec_asType( ) {
			assert( dataType is coreLibrary.type.Type );
			Symbol_Type type = typeUIDKeeper[ ctExec( ).readPrimitive!size_t ];
			benforce( type !is null, E.invalidPointer, "'%s' does not point to a valid type".format( identificationString ) );
			return type;
		}

	protected:
		/// These are only meant to be shortcut, identifier resolution should be also available "the second way" for example Class -> x and Class -> Type -> Class -> x
		Overloadset _resolveIdentifier_pre( Identifier id, MatchLevel matchLevel ) {
			return Overloadset( );
		}

		/// These are only meant to be shortcut, identifier resolution should be also available "the second way" for example Class -> x and Class -> Type -> Class -> x
		Overloadset _resolveIdentifier_main( Identifier id, MatchLevel matchLevel ) {
			return Overloadset( );
		}

	private:
		MatchLevel overloadMatch_;

}
