module beast.code.ast.stmt.break_;

import beast.code.ast.toolkit;

final class AST_BreakStatement : AST_Statement {

public:
	pragma(inline) static bool canParse() {
		return currentToken == Token.Keyword.break_;
	}

	/// Continues parsing after decoration list
	static AST_BreakStatement parse(CodeLocationGuard _gd, AST_DecorationList decorationList) {
		auto result = new AST_BreakStatement;
		benforce(decorationList is null, E.invalidDecoration, "Decorating a break statement is not allowed");

		currentToken.expectAndNext(Token.Keyword.break_);
		currentToken.expectAndNext(Token.Special.semicolon);

		result.codeLocation = _gd.get();
		return result;
	}

public:
	override void buildStatementCode(DeclarationEnvironment env, CodeBuilder cb) {
		const auto __gd = ErrorGuard(codeLocation);

		cb.build_break();
	}

protected:
	override SubnodesRange _subnodes() {
		return nodeRange();
	}

}
