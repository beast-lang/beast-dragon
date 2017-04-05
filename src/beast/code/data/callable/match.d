module beast.code.data.callable.match;

import beast.code.data.toolkit;
import beast.code.ast.expr.expression;

abstract class CallableMatch {

	public:
		this( DataEntity sourceDataEntity, MatchLevel initialMatchLevel = MatchLevel.fullMatch ) {
			sourceDataEntity_ = sourceDataEntity;
			matchLevel_ = initialMatchLevel;
		}

	public:
		final MatchLevel matchLevel( ) {
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
		pragma( inline ) final CallableMatch matchNextArgument( AST_Expression expression, DataEntity entity, Symbol_Type dataType ) {
			// No need for further matching
			if ( matchLevel_ == MatchLevel.noMatch )
				return this;

			matchLevel_ |= _matchNextArgument( expression, entity, dataType );
			argumentIndex_++;

			return this;
		}

		pragma( inline ) final CallableMatch matchNextArgument( DataEntity entity ) {
			auto result = matchNextArgument( null, entity, entity.dataType );
			return result;
		}

		alias arg = matchNextArgument;

		pragma( inline ) final CallableMatch finish( ) {
			debug finished_ = true;

			// No need for further matching
			if ( matchLevel_ == MatchLevel.noMatch )
				return this;

			matchLevel_ |= _finish( );
			
			return this;
		}

		/// Constructs a data entity that represents the function call expression
		pragma( inline ) final DataEntity toDataEntity( ) {
			assert( this );
			debug assert( finished_ );
			
			assert( matchLevel_ != MatchLevel.noMatch );

			return _toDataEntity( );
		}

		size_t argumentIndex() {
			return argumentIndex_;
		}

	protected:
		/// The actual matchLevel is minimal match level from all _matchNextArgument and _finish calls
		MatchLevel _matchNextArgument( AST_Expression expression, DataEntity entity, Symbol_Type dataType ) {
			return MatchLevel.fullMatch;
		}

		/// This is to handle for example when function requires more parameters than provided
		/// The actual matchLevel is minimal match level from all _matchNextArgument and _finish calls
		MatchLevel _finish( ) {
			return MatchLevel.fullMatch;
		}

		/// Creates and returns data entity that represents calling the function with given arguments
		DataEntity _toDataEntity( ) {
			assert( 0 );
		}

		final void errorStr( string set ) {
			errorStr_ = set;
		}

		final DataEntity sourceEntity( ) {
			return sourceDataEntity_;
		}

	protected:
		size_t argumentIndex_;

	private:
		MatchLevel matchLevel_;
		DataEntity sourceDataEntity_;
		string errorStr_;
		debug bool finished_ = false;

}
