module beast.code.data.scope_.scope_;

import beast.code.data.toolkit;
import beast.util.identifiable;
import beast.code.data.var.local;

/// "Scope" is where local variables exist; exiting the scope results in destroying them
/// Scope is expected to be accessed from one context only
abstract class DataScope : Identifiable {

	protected:
		this( DataEntity parentEntity ) {
			parentEntity_ = parentEntity;
			debug jobId_ = context.jobId;
		}

	public:
		/// Nearest DataEntity parent of the scope
		final DataEntity parentEntity( ) {
			return parentEntity_;
		}

		final override string identificationString( ) {
			if ( this is null )
				return "#error#";
				
			return parentEntity.identificationString;
		}

		final size_t itemCount() {
			return localVariables_.length;
		}

	public:
		final void addEntity( DataEntity entity_ ) {
			debug assert( context.jobId == jobId_ );
			debug assert( !isFinished_ );

			// Add to the overloadset
			if ( auto id = entity_.identifier ) {
				if ( auto it = id in groupedNamedVariables_ )
					it.data ~= entity_;
				else
					groupedNamedVariables_[ id ] = Overloadset( [ entity_ ] );
			}
		}

		final void addEntity( Symbol sym ) {
			addEntity( sym.dataEntity );
		}

		/// Adds variable to the scope
		final void addLocalVariable( DataEntity_LocalVariable var ) {
			localVariables_ ~= var;
			addEntity( var );
		}

	public:
		/// Builds a scope cleanup code (destruction of all variables in the scope)
		final void buildCleanup( CodeBuilder cb ) {
			debug assert( context.jobId == jobId_ );
			// TODO:
		}

		/// Cleans up the scope at compile time (calls destructors on local variables)
		final void ctimeCleanup() {
			scope cb = new CodeBuilder_Ctime();
			buildCleanup( cb );
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
