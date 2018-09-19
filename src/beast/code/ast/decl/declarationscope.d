module beast.code.ast.decl.declarationscope;

import beast.code.ast.decl.toolkit;

/// Module or class level declaration scope
final class AST_DeclarationScope : AST_Node {

public:
	static AST_DeclarationScope parse(AST_DecorationList rootDecorationList = null) {
		auto clg = codeLocationGuard();
		auto result = new AST_DeclarationScope;

		/// Current main scope decorations ( @decorator: xxx )
		AST_DecorationList scopeDecorationList = rootDecorationList;

		while (true) {

			// @decor @decor (something)
			if (AST_DecorationList.canParse) {
				AST_DecorationList decorationList = AST_DecorationList.parse();

				// @decor :
				if (currentToken.matchAndNext(Token.Special.colon)) {
					decorationList.parentDecorationList = rootDecorationList;
					scopeDecorationList = decorationList;
					result.commonDecorationLists_ ~= decorationList;
				}

				// @decor { xx }
			else if (currentToken.matchAndNext(Token.Special.lBrace)) {
					decorationList.parentDecorationList = scopeDecorationList;

					AST_DeclarationScope subScope = AST_DeclarationScope.parse(decorationList);
					result.subScopes_ ~= subScope;
					result.allDeclarations_ ~= subScope.allDeclarations_;

					currentToken.expectAndNext(Token.Special.rBrace, "declaration or '}'");
				}

				// @decor declaration;
			else if (AST_Declaration.canParse) {
					decorationList.parentDecorationList = scopeDecorationList;

					AST_Declaration declaration = AST_Declaration.parse(decorationList);
					result.directDeclarations_ ~= declaration;
				}

				else
					currentToken.reportSyntaxError("':', '{' or declaration");
			}

			// Declaration
			else if (AST_Declaration.canParse) {
				AST_Declaration declaration = AST_Declaration.parse(scopeDecorationList);
				result.directDeclarations_ ~= declaration;
			}

			// { block }
			else if (currentToken.matchAndNext(Token.Special.lBrace)) {
				AST_DeclarationScope subScope = AST_DeclarationScope.parse(scopeDecorationList);
				result.subScopes_ ~= subScope;
				result.allDeclarations_ ~= subScope.allDeclarations_;

				currentToken.expectAndNext(Token.Special.rBrace, "declaration or '}'");
			}

			else
				break;
		}

		result.allDeclarations_ ~= result.directDeclarations_;

		result.codeLocation = clg.get();
		return result;
	}

public:
	/// Processes the declarations, resulting in a symbol
	Symbol[] executeDeclarations(DeclarationEnvironment env) {
		Symbol[] result;

		foreach (decl; allDeclarations_)
			decl.executeDeclarations(env, (s) { result ~= s; });

		return result;
	}

protected:
	override SubnodesRange _subnodes() {
		return nodeRange(directDeclarations_, commonDecorationLists_, subScopes_);
	}

private:
	/// Declarations directly placed in the current declaration scope 
	AST_Declaration[] directDeclarations_; /// Declarations placed in the current declaration scope and its subscopes
	AST_Declaration[] allDeclarations_; /// Scope and block decoration lists
	AST_DecorationList[] commonDecorationLists_; /// Child scopes
	AST_DeclarationScope[] subScopes_;

}
