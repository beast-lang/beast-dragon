module beast.code.data.scope_.scope_;

import beast.code.data.toolkit;
import beast.code.data.var.local;
import beast.code.data.idcontainer;
import beast.util.uidgen;
import beast.code.data.scope_.local;
import beast.code.data.scope_.root;

/// DatScope is basically a namespace for data entities (the "Namespace" class stores symbols) - it is a namespace with a context
/// DataScope is not responsible for calling destructors or constructors - destructors are handled by a codebuilder
/// Scope is expected to be accessed from one context only
abstract class DataScope : IDContainer {

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
			debug assert( allowMultiThreadAccess || context.jobId == jobId_, "DataScope is accessed from a different thread than it was created in" );
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
		Overloadset tryResolveIdentifier( Identifier id, MatchLevel matchLevel = MatchLevel.fullMatch ) {
			debug assert( allowMultiThreadAccess || context.jobId == jobId_, "DataScope is accessed from a different thread than it was created in" );

			if ( auto result = id in groupedNamedVariables_ )
				return *result;

			return Overloadset( );
		}

	public:
		debug final UIDGenerator.I jobId( ) {
			return jobId_;
		}

	public:
		debug bool allowMultiThreadAccess;

	private:
		DataEntity parentEntity_;
		/// All local variables, both named and temporary ones
		DataEntity_LocalVariable[ ] localVariables_;
		Overloadset[ Identifier ] groupedNamedVariables_;

		debug UIDGenerator.I jobId_;
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

auto scopeGuard( DataScope scope_, bool finish = true ) {
	struct Result {
		~this( ) {
			assert( context.currentScope is scope_ );

			if ( finish )
				scope_.finish( );

			context.currentScope = context.scopeStack[ $ - 1 ];
			context.scopeStack.length--;
		}

		DataScope scope_;
		bool finish;
	}

	context.scopeStack ~= context.currentScope;
	context.currentScope = scope_;

	return Result( scope_, finish );
}

/// Executes given function in a new local data scope
pragma( inline ) auto inLocalDataScope( T )( lazy T dg ) {
	auto _gd = new LocalDataScope( ).scopeGuard;
	return dg( );
}

/// Executes given function in a new root data scope
pragma( inline ) auto inRootDataScope( T )( lazy T dg, DataEntity parent ) {
	auto _gd = new RootDataScope( parent ).scopeGuard;
	return dg( );
}
