module beast.code.ast.stmt.if_;

import beast.code.ast.toolkit;
import beast.code.decorationlist;
import beast.code.ast.stmt.statement;
import beast.backend.ctime.codebuilder;

final class AST_IfStatement : AST_Statement {

public:
	pragma(inline) static bool canParse() {
		return currentToken == Token.Keyword.if_;
	}

	/// Continues parsing after decoration list
	static AST_IfStatement parse(CodeLocationGuard _gd, AST_DecorationList decorationList) {
		auto result = new AST_IfStatement;
		result.decorationList = decorationList;

		currentToken.expectAndNext(Token.Keyword.if_);

		// Condition
		{
			currentToken.expectAndNext(Token.Special.lParent);
			result.condition = AST_Expression.parse();
			currentToken.expectAndNext(Token.Special.rParent);
		}

		result.thenBranch = AST_Statement.parse(null);

		if (currentToken.matchAndNext(Token.Keyword.else_))
			result.elseBranch = AST_Statement.parse(null);

		result.codeLocation = _gd.get();
		return result;
	}

public:
	override void buildStatementCode(DeclarationEnvironment env, CodeBuilder cb) {
		const auto __gd = ErrorGuard(codeLocation);

		auto decoList = scoped!DecorationList(decorationList);
		auto decoData = scoped!StatementDecorationData();

		decoList.apply_statementDecorator(decoData);
		decoList.enforceAllResolved();

		if (decoData.isCtime) {
			cb.build_scope((cb) { //
				if (condition.ctExec(coreType.Bool).keepUntilSessionEnd.readPrimitive!bool)
					thenBranch.buildStatementCode(env, cb).inLocalDataScope;
				else if (elseBranch)
					elseBranch.buildStatementCode(env, cb).inLocalDataScope;
			});
		}
		else {
			cb.build_if( //
					condition.buildSemanticTree_singleExpect(coreType.Bool), //
					(CodeBuilder cb) => thenBranch.buildStatementCode(env, cb).inLocalDataScope, //
					elseBranch ? (CodeBuilder cb) => elseBranch.buildStatementCode(env, cb).inLocalDataScope : null  //
					);
		}
	}

public:
	AST_DecorationList decorationList;
	AST_Expression condition;
	AST_Statement thenBranch, elseBranch;

protected:
	override SubnodesRange _subnodes() {
		// Decoration list can be inherited from decoration block or something, in that case we should not consider it a subnodes
		return nodeRange(condition, thenBranch, elseBranch);
	}

}
