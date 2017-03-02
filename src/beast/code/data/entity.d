module beast.code.data.entity;

import beast.code.data.toolkit;
import beast.util.identifiable;
import beast.code.data.scope_.root;
import beast.backend.ctime.codebuilder;

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
	Hash outerHash() {
		return parent.outerHash;
	}

public:
	/// Resolves identifier (drill-down)
	/// The scope can be used for creating temporary variables
	final Overloadset resolveIdentifier( Identifier id, DataScope scope_ ) {
		if ( auto result = resolveIdentifier_pre( id, scope_ ) )
			return result;

		if ( auto result = resolveIdentifier_main( id, scope_ ) )
			return result;

		if ( auto result = resolveIdentifier_post( id, scope_ ) )
			return result;

		return Overloadset( );
	}

	/// Resolves identifier recursively (looking into parent entities)
	/// The scope can be used for creating temporary variables
	Overloadset recursivelyResolveIdentifier( Identifier id, DataScope scope_ ) {
		if ( auto result = resolveIdentifier( id, scope_ ) )
			return result;

		if ( auto parent = parent ) {
			if ( auto result = parent.recursivelyResolveIdentifier( id, scope_ ) )
				return result;
		}

		return Overloadset( );
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
		assert( dataType is coreLibrary.types.Type );
		Symbol_Type type = typeUIDKeeper[ ctExec( scope_ ).readPrimitive!size_t ];
		benforce( type !is null, E.invalidPointer, "'%s' does not point to a valid type".format( identificationString ) );
		return type;
	}

protected:
	Overloadset resolveIdentifier_pre( Identifier id, DataScope scope_ ) {
		return Overloadset( );
	}

	Overloadset resolveIdentifier_main( Identifier id, DataScope scope_ ) {
		return Overloadset( );
	}

	Overloadset resolveIdentifier_post( Identifier id, DataScope scope_ ) {
		if ( auto dataType = dataType ) {
			if ( auto result = dataType.resolveIdentifier( id, scope_, this ) )
				return result;
		}

		return Overloadset( );
	}

}