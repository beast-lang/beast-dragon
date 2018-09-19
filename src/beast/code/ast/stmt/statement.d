module beast.code.ast.stmt.statement;

import beast.code.ast.toolkit;
import beast.code.ast.decl.declaration;
import beast.code.ast.stmt.return_;
import beast.code.ast.stmt.if_;
import beast.code.ast.stmt.codeblock;
import beast.code.ast.stmt.while_;
import beast.code.ast.stmt.break_;
import beast.code.ast.stmt.delete_;
import beast.code.ast.expr.decorated;

/// Statement is anything in the function body
abstract class AST_Statement : AST_Node {

public:
	pragma(inline) static bool canParse() {
		return ( //
				AST_Declaration.canParse || AST_Expression.canParse || AST_CodeBlockStatement.canParse //
				 || AST_ReturnStatement.canParse || AST_BreakStatement.canParse //
				 || AST_IfStatement.canParse || AST_WhileStatement.canParse //
				 || AST_DeleteStatement.canParse //
		);
	}

	static AST_Statement parse(AST_DecorationList decorationList) {
		auto _gd = codeLocationGuard();

		if (AST_DecorationList.canParse) {
			AST_DecorationList newDecorationList = AST_DecorationList.parse();
			newDecorationList.parentDecorationList = decorationList;
			decorationList = newDecorationList;
		}

		if (currentToken == Token.Keyword.auto_)
			return AST_Declaration.parse(decorationList);

		// RETURN / BREAK / CONTINUE
		else if (AST_ReturnStatement.canParse)
			return AST_ReturnStatement.parse(_gd, decorationList);

		else if (AST_BreakStatement.canParse)
			return AST_BreakStatement.parse(_gd, decorationList);

		// BRANCHING
		else if (AST_IfStatement.canParse)
			return AST_IfStatement.parse(_gd, decorationList);

		else if (AST_WhileStatement.canParse)
			return AST_WhileStatement.parse(_gd, decorationList);

		// SPECIAL
		else if (AST_CodeBlockStatement.canParse)
			return AST_CodeBlockStatement.parse(_gd, decorationList);

		else if (AST_DeleteStatement.canParse)
			return AST_DeleteStatement.parse(_gd, decorationList);

		else if (AST_Expression.canParse) {
			AST_Expression expr = AST_Expression.parse(false);

			// expr identifier => declaration
			if (currentToken == Token.Type.identifier) {
				benforce(expr.isPrefixExpression, E.syntaxError, "Syntax error - either unexpected identifier or type expression uses forbidden operators", (msg) { msg.codeLocation = currentToken.codeLocation; });

				return AST_Declaration.parse(_gd, decorationList, expr);
			}
			else {
				if (decorationList) {
					expr = new AST_DecoratedExpression(decorationList, expr);
					expr.codeLocation = _gd.get();
				}

				// Otherwise just expression statement
				currentToken.expectAndNext(Token.Special.semicolon, "semicolon after expression");
				return expr;
			}
		}

		currentToken.reportSyntaxError("statement");
		assert(0);
	}

public:
	/// Builds code representing the statement using given code builder in the given scope
	abstract void buildStatementCode(DeclarationEnvironment env, CodeBuilder cb);

}

final class StatementDecorationData {

public:
	bool isCtime;

}
