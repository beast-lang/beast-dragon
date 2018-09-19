module beast.code.ast.expr.binary;

import beast.code.ast.toolkit;
import beast.code.data.symbol;
import beast.code.data.matchlevel;

DataEntity resolveBinaryOperation(AST_Node ast, DataEntity left, AST_Expression rightExpr, DataEntity binXX, Token.Operator op) {
	import std.range : chain;

	// First we try left.#opBinary( binXX, rightExpr )
	CallMatchSet leftCall = left.tryResolveIdentifier(ID!"#opBinary").CallMatchSet(ast, false).arg(binXX).arg(rightExpr);
	if (auto result = leftCall.finish())
		return result;

	// If looking for left.#opBinary( binXX, rightExpr ) failed, we build right side and try right.#opBinaryR( binXX, left )
	DataEntity right = rightExpr.buildSemanticTree(null, false).single;

	benforce(right !is null, E.cannotResolve, "Cannot resolve %s %s %s:%s".format( //
			left.dataType.identificationString, Token.operatorStr[op], right.dataType.identificationString, //
			leftCall.matches.map!(x => "\n\n\t%s:\n\t\t%s".format(x.sourceDataEntity.tryGetIdentificationString, x.errorStr)).joiner //
			));

	CallMatchSet rightCall = right.tryResolveIdentifier(ID!"#opBinaryR").CallMatchSet(ast, false).arg(binXX).arg(left);
	if (auto result = rightCall.finish())
		return result;

	berror(E.cannotResolve, "Cannot resolve %s %s %s:%s".format( //
			left.dataType.identificationString, Token.operatorStr[op], right.dataType.identificationString, //
			chain(leftCall.matches, rightCall.matches).map!(x => "\n\t%s:\n\t\t%s\n".format(x.sourceDataEntity.identificationString, x.errorStr)).joiner //
			));
	assert(0);
}

DataEntity resolveBinaryOperation(AST_Node ast, DataEntity left, DataEntity right, DataEntity binXX, Token.Operator op) {
	import std.range : chain;

	// First we try left.#opBinary( binXX, rightExpr )
	CallMatchSet leftCall = left.tryResolveIdentifier(ID!"#opBinary").CallMatchSet(ast, false).arg(binXX).arg(right);
	if (auto result = leftCall.finish())
		return result;

	CallMatchSet rightCall = right.tryResolveIdentifier(ID!"#opBinaryR").CallMatchSet(ast, false).arg(binXX).arg(left);
	if (auto result = rightCall.finish())
		return result;

	berror(E.cannotResolve, "Cannot resolve %s %s %s:%s".format( //
			left.dataType.identificationString, Token.operatorStr[op], right.dataType.identificationString, //
			chain(leftCall.matches, rightCall.matches).map!(x => "\n\t%s:\n\t\t%s\n".format(x.sourceDataEntity.identificationString, x.errorStr)).joiner //
			));
	assert(0);
}
