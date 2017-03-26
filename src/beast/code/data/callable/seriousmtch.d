module beast.code.data.callable.seriousmtch;

import beast.code.data.callable.match;
import beast.code.data.toolkit;
import beast.code.ast.expr.expression;
import beast.code.data.scope_.blurry;

/// You wanna use this class, it implements lot of utility stuff
abstract class SeriousCallableMatch : CallableMatch {
	public:
		this( DataEntity sourceDataEntity, AST_Node ast, bool isOnlyOverloadOption, MatchLevel initialMatchLevel = MatchLevel.fullMatch ) {
			super( sourceDataEntity, initialMatchLevel );
			assert( currentScope );

			scope__ = new BlurryDataScope( currentScope );
			ast_ = ast;
			isOnlyOverloadOption_ = isOnlyOverloadOption;
		}

	public:
		final BlurryDataScope scope_( ) {
			return scope__;
		}

		final AST_Node ast( ) {
			return ast_;
		}

	protected:
		override MatchLevel _finish( ) {
			scope__.finish( );
			return MatchLevel.fullMatch;
		}

	public:
		final MatchLevel matchStandardArgument( AST_Expression expression, ref DataEntity entity, ref Symbol_Type dataType, Symbol_Type expectedType ) {
			MatchLevel result = MatchLevel.fullMatch;

			/// If the expression needs expectedType to be parsed, parse it with current parameter type as expected
			if ( !entity ) {
				with ( memoryManager.session ) {
					entity = expression.buildSemanticTree_singleInfer( expectedType, isOnlyOverloadOption_ );

					if ( !entity ) {
						errorStr = "cannot process argument %s (expected type %s)".format( argumentIndex_ + 1, expectedType.identificationString );
						return MatchLevel.noMatch;
					}

					dataType = entity.dataType;
					result |= MatchLevel.inferrationsNeeded;
				}
			}

			if ( dataType !is expectedType ) {
				entity = entity.tryCast( expectedType );

				if ( !entity ) {
					errorStr = "cannot cast argument %s of type %s to %s".format( argumentIndex_ + 1, dataType.identificationString, expectedType.identificationString );
					return MatchLevel.noMatch;
				}

				dataType = expectedType;
				result |= MatchLevel.implicitCastsNeeded;
			}

			return result;
		}

		final MatchLevel matchCtimeArgument( AST_Expression expression, ref DataEntity entity, ref Symbol_Type dataType, Symbol_Type expectedType, ref MemoryPtr value ) {
			MatchLevel result = MatchLevel.fullMatch;

			result |= matchStandardArgument( expression, entity, dataType, expectedType );
			if ( result == MatchLevel.noMatch )
				return MatchLevel.noMatch;

			if ( !entity.isCtime ) {
				errorStr = "argument %s not ctime, cannot compare".format( argumentIndex_ + 1 );
				return MatchLevel.noMatch;
			}

			value = entity.ctExec( );

			return result;
		}

		final MatchLevel matchConstValue( AST_Expression expression, ref DataEntity entity, ref Symbol_Type dataType, Symbol_Type expectedType, MemoryPtr requiredValue ) {
			MatchLevel result = MatchLevel.fullMatch;
			MemoryPtr value;

			result |= matchCtimeArgument( expression, entity, dataType, expectedType, value );
			if ( result == MatchLevel.noMatch )
				return MatchLevel.noMatch;

			if ( !value.dataEquals( requiredValue, expectedType.instanceSize ) ) {
				errorStr = "argument %s value mismatch".format( argumentIndex_ + 1 );
				return MatchLevel.noMatch;
			}

			return result;
		}

	private:
		BlurryDataScope scope__;
		AST_Node ast_;

		/// When the match is only overload option, inferration errors are reported directly
		bool isOnlyOverloadOption_;

}