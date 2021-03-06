module beast.code.semantic.callable.seriousmtch;

import beast.code.semantic.callable.match;
import beast.code.semantic.toolkit;
import beast.code.ast.expr.expression;
import beast.code.semantic.scope_.blurry;

/// You wanna use this class, it implements lot of utility stuff
abstract class SeriousCallableMatch : CallableMatch {
public:
	this(DataEntity sourceDataEntity, AST_Node ast, bool canThrowErrors, MatchLevel initialMatchLevel = MatchLevel.fullMatch) {
		super(sourceDataEntity, initialMatchLevel);
		assert(currentScope);

		scope__ = new BlurryDataScope(currentScope);
		ast_ = ast;
		isOnlyOverloadOption_ = canThrowErrors;
	}

public:
	final BlurryDataScope scope_() {
		return scope__;
	}

	final AST_Node ast() {
		return ast_;
	}

protected:
	override MatchLevel _finish() {
		scope__.finish();
		return MatchLevel.fullMatch;
	}

public:
	final MatchLevel matchAutoArgument(AST_Expression expression, ref DataEntity entity, ref Symbol_Type dataType) {
		MatchLevel result = MatchLevel.inferrationsNeeded;

		/// If the expression needs expectedType to be parsed, parse it with current parameter type as expected
		if (!entity) {
			errorStr = "cannot infer argument %s".format(argumentIndex_ + 1);
			return MatchLevel.noMatch;
		}

		dataType = entity.dataType;

		return result;
	}

	final MatchLevel matchStandardArgument(AST_Expression expression, ref DataEntity entity, ref Symbol_Type dataType, Symbol_Type expectedType) {
		MatchLevel result = MatchLevel.fullMatch;

		/// If the expression needs expectedType to be parsed, parse it with current parameter type as expected
		if (!entity) {
			entity = expression.buildSemanticTree_singleInfer(expectedType, isOnlyOverloadOption_).inSession(SessionPolicy.inheritCtChangesWatcher);

			if (!entity) {
				errorStr = "cannot process argument %s (expected type %s)".format(argumentIndex_ + 1, expectedType.identificationString);
				return MatchLevel.noMatch;
			}

			dataType = entity.dataType;
			result |= MatchLevel.inferrationsNeeded;
		}

		if (expectedType && dataType !is expectedType) {
			entity = entity.tryCast(expectedType).inSubSession;

			if (!entity) {
				errorStr = "cannot cast argument %s of type %s to %s".format(argumentIndex_ + 1, dataType.identificationString, expectedType.identificationString);
				return MatchLevel.noMatch;
			}

			dataType = expectedType;
			result |= MatchLevel.implicitCastsNeeded;
		}

		return result;
	}

	final MatchLevel matchCtimeArgument(AST_Expression expression, ref DataEntity entity, ref Symbol_Type dataType, Symbol_Type expectedType, ref CTExecResult ctexec) {
		MatchLevel result = MatchLevel.fullMatch;

		result |= matchStandardArgument(expression, entity, dataType, expectedType);
		if (result == MatchLevel.noMatch)
			return MatchLevel.noMatch;

		if (!entity.isCtime) {
			errorStr = "argument %s not ctime, cannot compare".format(argumentIndex_ + 1);
			return MatchLevel.noMatch;
		}

		ctexec = entity.ctExec();

		return result;
	}

	final MatchLevel matchConstValue(AST_Expression expression, ref DataEntity entity, ref Symbol_Type dataType, Symbol_Type expectedType, MemoryPtr requiredValue) {
		MatchLevel result = MatchLevel.fullMatch;
		CTExecResult ctexec;

		result |= matchCtimeArgument(expression, entity, dataType, expectedType, ctexec);
		if (result == MatchLevel.noMatch)
			return MatchLevel.noMatch;

		if (!ctexec.value.dataEquals(requiredValue, expectedType.instanceSize)) {
			errorStr = "argument %s value mismatch".format(argumentIndex_ + 1);
			return MatchLevel.noMatch;
		}

		// TODO: Scope generated by ctexec should be inserted on the code builder stack or discarded

		return result;
	}

private:
	BlurryDataScope scope__;
	AST_Node ast_;

	/// When the match is only overload option, inferration errors are reported directly
	bool isOnlyOverloadOption_;

}
