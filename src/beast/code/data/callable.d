module beast.code.data.callable;

import beast.code.data.toolkit;
import beast.code.ast.expr.expression;
import beast.code.data.scope_.blurry;

abstract class CallableMatch {

	public:
		enum MatchFlags {
			fullMatch = 0, /// All types match
			noMatch = -1, /// Function does not match the arguments at all
			implicitCastsNeeded = 1 << 0, /// At least one implicit cast was needed
			inferrationsNeeded = 1 << 1, /// At least one inferration was needed
			staticCall = 1 << 2, /// Called static function via an object instance // TODO: this is not handled at all so far
		}

	public:
		this( DataEntity sourceDataEntity ) {
			sourceDataEntity_ = sourceDataEntity;
		}

	public:
		final MatchFlags matchLevel( ) {
			debug assert( finished_ );
			return matchLevel_;
		}

		/// Callable data entity this match is done for
		final DataEntity sourceDataEntity( ) {
			return sourceDataEntity_;
		}

		/// When the match is noMatch, this should return why does it not match
		final string errorStr( ) {
			return errorStr_;
		}

	public:
		/// Tries to match next argument with the given function.
		/// If the expression could have been processed into data entity without inferredType, passes the entity and dataType as arguments (use these instead of building the semantic tree again).
		final CallableMatch matchNextArgument( AST_Expression expression, DataEntity entity, Symbol_Type dataType ) {
			// No need for further matching
			if ( matchLevel_ == MatchFlags.noMatch )
				return this;

			matchLevel_ |= _matchNextArgument( expression, entity, dataType );
			return this;
		}

		final CallableMatch matchNextArgument( DataEntity entity ) {
			return matchNextArgument( null, entity, entity.dataType );
		}

		final void finish( ) {
			debug finished_ = true;

			// No need for further matching
			if ( matchLevel_ == MatchFlags.noMatch )
				return;

			matchLevel_ |= _finish( );
		}

		/// Constructs a data entity that represents the function call expression
		final DataEntity toDataEntity( ) {
			debug assert( finished_ );
			assert( matchLevel_ != MatchFlags.noMatch );

			return _toDataEntity( );
		}

	protected:
		/// The actual matchLevel is minimal match level from all _matchNextArgument and _finish calls
		MatchFlags _matchNextArgument( AST_Expression expression, DataEntity entity, Symbol_Type dataType ) {
			return MatchFlags.fullMatch;
		}

		/// This is to handle for example when function requires more parameters than provided
		/// The actual matchLevel is minimal match level from all _matchNextArgument and _finish calls
		MatchFlags _finish( ) {
			return MatchFlags.fullMatch;
		}

		/// Creates and returns data entity that represents calling the function with given arguments
		DataEntity _toDataEntity( ) {
			assert( 0 );
		}

		final void errorStr( string set ) {
			errorStr_ = set;
		}

	private:
		MatchFlags matchLevel_ = MatchFlags.fullMatch;
		DataEntity sourceDataEntity_;
		string errorStr_;
		debug bool finished_ = false;

}

abstract class SeriousCallableMatch : CallableMatch {
	public:
		this( DataScope scope_, DataEntity sourceDataEntity, AST_Node ast ) {
			super( sourceDataEntity );
			scope__ = new BlurryDataScope( scope_ );
			ast_ = ast;
		}

	public:
		final BlurryDataScope scope_( ) {
			return scope__;
		}

		final AST_Node ast( ) {
			return ast_;
		}

	private:
		BlurryDataScope scope__;
		AST_Node ast_;

}

/// When it is certain that the function call has no match from the beginning (for example when calling a member function without a context instance)
final class InvalidCallableMatch : CallableMatch {

	public:
		this( DataEntity sourceDataEntity, string errorStr ) {
			super( sourceDataEntity );

			this.errorStr = errorStr;
		}

	protected:
		final override MatchFlags _finish( ) {
			return MatchFlags.noMatch;
		}

}
