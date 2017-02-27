module beast.code.data.entitycontainer.scope_.scope_;

import beast.code.data.toolkit;
import beast.core.task.context;
import beast.core.task.context;
import beast.code.data.entitycontainer.container;

/// "Scope" is where local variables exist; exiting the scope results in destroying them
/// Scope is expected to be accessed from one context only
abstract class DataScope : EntityContainer {

public:
	this( ) {
		debug jobId_ = context.jobId;
	}

public:
	final override bool isScope( ) {
		return true;
	}

	final override Namespace asNamespace( ) {
		assert( 0 );
	}

	final override DataScope asScope( ) {
		return this;
	}

public:
	debug final size_t jobId( ) {
		return jobId_;
	}

	final ref size_t currentBasePointerOffset( ) {
		return currentBasePointerOffset_;
	}

public:
	/// Adds variable to the scope
	final void addLocalVariable( DataEntity_LocalVariable var ) {
		debug assert( context.jobId == jobId_ );
		debug assert( !isFinished_ );

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

	/// Marks the scope as not being editable anymore
	void finish( ) {
		debug {
			assert( !isFinished_ );
			isFinished_ = true;
		}
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

	size_t currentBasePointerOffset_;

	debug size_t jobId_;
	debug bool isFinished_;

package:
	debug DataScope openSubscope_;

}
