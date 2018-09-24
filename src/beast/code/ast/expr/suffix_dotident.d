module beast.code.ast.expr.suffix_dotident;

import beast.code.ast.toolkit;
import beast.code.ast.expr.suffix;
import beast.code.ast.identifier;
import beast.code.ast.expr.parentcomma;

/// expr.ident
final class AST_Suffix_DotIdent : AST_Node, AST_SuffixExpressionItem {

public:
	static bool canParse() {
		return currentToken == Token.Special.dot;
	}

	static AST_SuffixExpressionItem parse() {
		auto _gd = codeLocationGuard();
		auto result = new AST_Suffix_DotIdent();

		currentToken.expectAndNext(Token.Special.dot);

		result.identifier = AST_Identifier.parse();

		result.codeLocation = _gd.get();
		return result;
	}

public:
	AST_Identifier identifier;

public:
	override Overloadset p1expressionItem_buildSemanticTree(Overloadset leftSide, bool ctime) {
		const auto __gd = ErrorGuard(codeLocation);
		return leftSide.single.expectResolveIdentifier(identifier);
	}

	override AST_ParentCommaExpression isParentCommaExpression() {
		return null;
	}

protected:
	override SubnodesRange _subnodes() {
		return nodeRange(identifier);
	}

}
