module beast.code.data.scope_.scope_;

import beast.code.data.toolkit;
import beast.core.task.context;
import beast.core.task.context;

/// "Scope" is where local variables exist; exiting the scope results in destroying them
/// Scope is expected to be accessed from one context only
abstract class DataScope : Identifiable {

protected:
	this( DataEntity parentEntity ) {
		parentEntity_ = parentEntity;
		debug jobId_ = context.jobId;
	}

public:
	final ref size_t currentBasePointerOffset( ) {
		return currentBasePointerOffset_;
	}

	/// Nearest DataEntity parent of the scope
	final DataEntity parentEntity( ) {
		return parentEntity_;
	}

	final override string identificationString() {
		return parentEntity.identificationString;
	}

public:
	/// Adds variable to the scope
	final void addLocalVariable( DataEntity_LocalVariable var ) {
		debug assert( context.jobId == jobId_ );
		debug assert( !isFinished_ );

		localVariables_ ~= var;

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
	Overloadset resolveIdentifier( Identifier id, DataScope scope_ ) {
		debug assert( context.jobId == jobId_ );

		if ( auto result = id in groupedNamedVariables_ )
			return *result;

		return Overloadset( );
	}

	abstract Overloadset recursivelyResolveIdentifier( Identifier id, DataScope scope_ );

protected:
	debug final size_t jobId( ) {
		return jobId_;
	}

private:
	DataEntity parentEntity_;
	/// All local variables, both named and temporary ones
	DataEntity_LocalVariable[ ] localVariables_;
	Overloadset[ Identifier ] groupedNamedVariables_;

	size_t currentBasePointerOffset_;

	public debug size_t jobId_;
	debug bool isFinished_;

package:
	/// Currently open subscope (used for checking there's maximally one at a time)
	debug DataScope openSubscope_;

}
