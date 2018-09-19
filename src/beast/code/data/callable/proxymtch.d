module beast.code.data.callable.proxymtch;

import beast.code.data.toolkit;
import beast.code.data.callable.match;
import beast.code.ast.expr.expression;

/// Proxy passes the match to another match (used for example for aliases)
final class ProxyCallableMatch : CallableMatch {

public:
	this(DataEntity sourceDataEntity, CallableMatch sourceMatch) {
		super(sourceDataEntity);

		sourceMatch_ = sourceMatch;
	}

protected:
	override MatchLevel _matchNextArgument(AST_Expression expression, DataEntity entity, Symbol_Type dataType) {
		sourceMatch_.matchNextArgument(expression, entity, dataType);
		return MatchLevel.fullMatch;
	}

	override MatchLevel _finish() {
		sourceMatch_.finish();
		errorStr = sourceMatch_.errorStr;
		return sourceMatch_.matchLevel;
	}

	override DataEntity _toDataEntity() {
		return sourceMatch_.toDataEntity;
	}

private:
	CallableMatch sourceMatch_;

}
