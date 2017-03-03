module beast.code.data.callable;

import beast.code.data.toolkit;
import beast.code.data.scope_.blurry;
import beast.code.ast.expr.expression;

abstract class CallableMatch {

	public:
		enum Level {
			noMatch, /// Function does not match the arguments at all
			implicitCastsNeeded, /// At least one implicit cast was needed
			inferrationsNeeded, /// At least one inferration was needed
			fullMatch /// All types match
		}

	public:
		this( DataScope scope_, DataEntity sourceDataEntity, AST_Node ast ) {
			scope__ = new BlurryDataScope( scope_ );
			sourceDataEntity_ = sourceDataEntity;
			ast_ = ast;
		}

	public:
		final BlurryDataScope scope_( ) {
			return scope__;
		}

		final AST_Node ast( ) {
			return ast_;
		}

		final Level matchLevel( ) {
			debug assert( finished_ );
			return matchLevel_;
		}

		/// Callable data entity this match is done for
		final DataEntity sourceDataEntity( ) {
			return sourceDataEntity_;
		}

	public:
		/// Tries to match next argument with the given function.
		/// If the expression could have been processed into data entity without expectedType, passes the entity and dataType as arguments (use these instead of building the semantic tree again).
		final void matchNextArgument( AST_Expression expression, DataEntity entity, Symbol_Type dataType ) {
			// No need for further matching
			if ( matchLevel_ == Level.noMatch )
				return;

			const auto lvl = _matchNextArgument( expression, entity, dataType );
			if ( lvl < matchLevel_ )
				matchLevel_ = lvl;
		}

		final void finish( ) {
			debug finished_ = true;
			
			// No need for further matching
			if ( matchLevel_ == Level.noMatch )
				return;

			const auto lvl = _finish( );
			if ( lvl < matchLevel_ )
				matchLevel_ = lvl;
		}

		/// Constructs a data entity that represents the function call expression
		final DataEntity toDataEntity( ) {
			debug assert( finished_ );
			assert( matchLevel_ != Level.noMatch );

			return _toDataEntity( );
		}

	protected:
		/// The actual matchLevel is minimal match level from all _matchNextArgument and _finish calls
		abstract Level _matchNextArgument( AST_Expression expression, DataEntity entity, Symbol_Type dataType );

		/// This is to handle for example when function requires more parameters than provided
		/// The actual matchLevel is minimal match level from all _matchNextArgument and _finish calls
		abstract Level _finish( );

		abstract DataEntity _toDataEntity( );

	private:
		Level matchLevel_ = Level.fullMatch;
		BlurryDataScope scope__;
		DataEntity sourceDataEntity_;
		AST_Node ast_;
		debug bool finished_ = false;

}
