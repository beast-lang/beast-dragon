module beast.code.data.entity;

import beast.code.data.toolkit;
import beast.util.identifiable;
import beast.code.data.callable;
import beast.core.project.codelocation;
import beast.code.memory.ptr;
import beast.code.data.type.type;
import beast.code.data.decorator.decorator;

/// DataEntity stores information about a value: what is its type and how to obtain it (how to build code that obtains it)
/// It is practically a semantic tree node
abstract class DataEntity : Identifiable {

	public:
		/// Type of the data; can be null (mostly when reflection is not implemented)
		abstract Symbol_Type dataType( );

		/// Parent of the current data entity, is used in recursive identifier resolution
		abstract DataEntity parent( );

		/// If the data is known at compile time
		/// This can be false even if the entity is inferable at compile time (for example function calls)
		/// This is mostly used in operator overloading (ctime vs nonctime overloads)
		abstract bool isCtime( );

		/// Returns if the current entity is callable
		bool isCallable( ) {
			return false;
		}

		/// Creates a class instance that is in charge of matching the currect callable entity with an argument list
		CallableMatch startCallMatch( DataScope scope_, AST_Node ast ) {
			assert( 0, identificationString ~ " is not callable" );
		}

		Symbol_Decorator isDecorator( ) {
			return null;
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

			return "(expression)";
		}

		string identificationString( ) {
			if ( this is null )
				return "#error#";

			if ( auto parent = parent )
				return parent.identificationString ~ "." ~ identification;

			return identification;
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
		/// Resolves identifier (drill-down)
		/// The scope can be used for creating temporary variables
		final Overloadset resolveIdentifier( Identifier id, DataScope scope_ ) {
			if ( id == ID!"#type" )
				return Overloadset( dataType.dataEntity );

			if ( auto result = _resolveIdentifier_pre( id, scope_ ) )
				return result;

			if ( auto result = _resolveIdentifier_main( id, scope_ ) )
				return result;

			if ( auto result = dataType.resolveIdentifier( id, scope_, this ) )
				return result;

			return Overloadset( );
		}

		/// Resolves the identifier, throws an error if the overloadset is empty
		final Overloadset expectResolveIdentifier( Identifier id, DataScope scope_ ) {
			auto result = resolveIdentifier( id, scope_ );
			benforce( !result.isEmpty, E.unknownIdentifier, "Could not resolve identifier '%s' for %s".format( id.str, identificationString ) );
			return result;
		}

		/// Resolves identifier recursively (looking into parent entities)
		/// The scope can be used for creating temporary variables
		final Overloadset recursivelyResolveIdentifier( Identifier id, DataScope scope_ ) {
			if ( auto result = resolveIdentifier( id, scope_ ) )
				return result;

			if ( auto parent = parent ) {
				if ( auto result = parent.recursivelyResolveIdentifier( id, scope_ ) )
					return result;
			}

			return Overloadset( );
		}

		/// Enforces that the resulting entity is of dataType targetType (either returns itself or creates a cast call)
		DataEntity enforceCast( Symbol_Type targetType ) {
			if ( dataType == targetType )
				return this;

			DataEntity result = tryCast( targetType );
			benforce( result !is null, E.notImplemented, "Casting is not implemented yet" );

			return result;
		}

		/// Tries to cast to the targetType (or returns itself if already is of targe type). Returns null on failure
		DataEntity tryCast( Symbol_Type targetType ) {
			if ( dataType == targetType )
				return this;

			/// TODO: Implicit cast check
			/// TODO: alias this check
			return null;
		}

	public:
		/// Builds code that matches the semantic tree (scope is used for variable allocations)
		void buildCode( CodeBuilder cb, DataScope scope_ ) {
			assert( 0, "buildCode not implemented for " ~ identificationString );
		}

	public:
		/// Executes the expression in standalone scope and session, returing its value
		final MemoryPtr ctExec( DataScope scope_ ) {
			scope cb = new CodeBuilder_Ctime;
			buildCode( cb, scope_ );
			return cb.result;
		}

		/// Expects the data to point at Type instance
		final Symbol_Type ctExec_asType( DataScope scope_ ) {
			assert( dataType is coreLibrary.type.Type );
			Symbol_Type type = typeUIDKeeper[ ctExec( scope_ ).readPrimitive!size_t ];
			benforce( type !is null, E.invalidPointer, "'%s' does not point to a valid type".format( identificationString ) );
			return type;
		}

	protected:
		/// These are only meant to be shortcut, identifier resolution should be also available "the second way" for example Class -> x and Class -> Type -> Class -> x
		Overloadset _resolveIdentifier_pre( Identifier id, DataScope scope_ ) {
			return Overloadset( );
		}

		/// These are only meant to be shortcut, identifier resolution should be also available "the second way" for example Class -> x and Class -> Type -> Class -> x
		Overloadset _resolveIdentifier_main( Identifier id, DataScope scope_ ) {
			return Overloadset( );
		}

}
