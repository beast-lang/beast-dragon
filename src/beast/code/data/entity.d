module beast.code.data.entity.entity;

import beast.code.data.toolkit;
import beast.util.identifiable;
import beast.code.data.entitycontainer.scope_.root;
import beast.backend.ctime.codebuilder;

/// DataEntity stores information about a value: what is its type and how to obtain it (how to build code that obtains it)
/// It is practically a semantic tree node
abstract class DataEntity : Identifiable {


public:
	/// Type of the data
	abstract Symbol_Type dataType( );

	/// Scope of the data (the data is valid only during existence of the scope) - may be null => global scope
	DataScope scope_;

	/// If the data is known at compiletime
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
		return ( scope_ ? scope_.identificationString ~ "." : "" ) ~ identification;
	}

	abstract AST_Node ast( );

public:
	Overloadset resolveIdentifier( Identifier id ) {
		if ( auto result = dataType.resolveIdentifier( id, this ) )
			return result;

		return Overloadset( );
	}

public:
	/// Builds code that matches the semantic tree (scope is used for variable allocations)
	abstract void buildCode( CodeBuilder cb, DataScope scope_ );

	/// Executes the expression in standalone scope and session, returing its value
	final MemoryPtr ctExec( DataScope scope_ ) {
		CodeBuilder_Ctime cb = new CodeBuilder_Ctime;
		buildCode( cb, scope_ );
		return cb.result;
	}

	/*public:
	/// Expects the data to point at Type instance
	final Symbol_Type ctValue_Type( ) {
		assert( dataType is coreLibrary.types.Type );
		Symbol_Type type = typeUIDKeeper[ ctValue.readPrimitive!size_t ];
		benforce( type !is null, E.invalidPointer, "'%s' does not point to a valid type".format( identificationString ) );
		return type;
	}*/

}
