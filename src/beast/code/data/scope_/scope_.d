module beast.code.data.scope_.scope_;

import beast.code.data.toolkit;
import beast.util.identifiable;
import beast.code.data.var.local;

/// DatScope is basically a namespace for data entities (the "Namespace" class stores symbols) - it is a namespace with a context
/// DataScope is not responsible for calling destructors or constructors - destructors are handled by a codebuilder
/// Scope is expected to be accessed from one context only
abstract class DataScope : Identifiable {

	protected:
		this( DataEntity parentEntity ) {
			parentEntity_ = parentEntity;
			debug jobId_ = context.jobId;
		}

		~this( ) {
			//debug assert( isFinished_, "Scope destroyed but not finished" );
		}

	public:
		/// Nearest DataEntity parent of the scope
		final DataEntity parentEntity( ) {
			return parentEntity_;
		}

		final override string identificationString( ) {
			return parentEntity.identificationString;
		}

		final size_t itemCount( ) {
			return localVariables_.length;
		}

	public:
		final void addEntity( DataEntity entity_ ) {
			debug assert( context.jobId == jobId_ );
			debug assert( !isFinished_ );

			auto id = entity_.identifier;
			assert( id, "You cannot add entities without an identifier to a scope" );

			// Add to the overloadset
			if ( auto it = id in groupedNamedVariables_ )
				it.data ~= entity_;
			else
				groupedNamedVariables_[ id ] = Overloadset( [ entity_ ] );
		}

		final void addEntity( Symbol sym ) {
			addEntity( sym.dataEntity );
		}

		/// Adds variable to the scope
		final void addLocalVariable( DataEntity_LocalVariable var ) {
			localVariables_ ~= var;
			addEntity( var );
		}

		/// Marks the scope as not being editable anymore
		void finish( ) {
			debug {
				assert( !isFinished_, "Duplicate finish() of scope" );
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

		abstract Overloadset recursivelyResolveIdentifier( Identifier id );

	public:
		debug final size_t jobId( ) {
			return jobId_;
		}

	private:
		DataEntity parentEntity_;
		/// All local variables, both named and temporary ones
		DataEntity_LocalVariable[ ] localVariables_;
		Overloadset[ Identifier ] groupedNamedVariables_;

		debug size_t jobId_;
		debug bool isFinished_;

	package:
		/// Currently open subscope (used for checking there's maximally one at a time)
		debug DataScope openSubscope_;

}

/// Returns current scope for the current context
DataScope currentScope( ) {
	assert( context.currentScope );
	return context.currentScope;
}

ScopeGuard scopeGuard( DataScope scope_ ) {
	return ScopeGuard( scope_ );
}

private struct ScopeGuard {

	public:
		this( DataScope scope_ ) {
			context.scopeStack ~= context.currentScope;
			context.currentScope = scope_;

			debug this.scope_ = scope_;
		}

		~this( ) {
			debug assert( context.currentScope is scope_ );
			assert( context.scopeStack.length );

			context.currentScope = context.scopeStack[ $ - 1 ];
			context.scopeStack.length--;
		}

	private:
		debug DataScope scope_;

}
