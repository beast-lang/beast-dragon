module beast.code.data.scope_.scope_;

import beast.code.data.toolkit;
import beast.core.task.context;
import beast.core.task.context;

/// "Scope" is where local variables exist; exiting the scope results in destroying them
/// Scope is expected to be accessed from one context only
abstract class DataScope : Identifiable {

public:
	this( ) {
		debug jobId_ = context.jobId;
	}

public:
	debug final size_t jobId( ) {
		return jobId_;
	}

	abstract ref size_t currentBasePointerOffset( );

public:
	/// Adds variable to the scope
	final void addVariable( DataEntity_LocalVariable var ) {
		debug assert( context.jobId == jobId_ );
		allVariables_ ~= var;

		// Add to the overloadset
		if ( auto id = var.identifier ) {
			if ( auto it = id in groupedNamedVariables_ )
				it.data ~= var;
			else
				groupedNamedVariables_[ id ] = Overloadset( [ var ] );
		}
	}

public:
	/// Builds a scope cleanup code (destruction of all variables in the scope)
	final void buildCleanup( CodeBuilder cb ) {
		debug assert( context.jobId == jobId_ );
		// TODO:
	}

public:
	Overloadset resolveIdentifier( Identifier id ) {
		debug assert( context.jobId == jobId_ );

		if ( auto result = id in groupedNamedVariables_ )
			return *result;

		return Overloadset( );
	}

	Overloadset resolveIdentifierRecursively( Identifier id ) {
		if ( auto result = resolveIdentifier( id ) )
			return result;

		return Overloadset( );
	}

private:
	DataEntity_LocalVariable[ ] allVariables_;
	Overloadset[ Identifier ] groupedNamedVariables_;
	debug size_t jobId_;

}
