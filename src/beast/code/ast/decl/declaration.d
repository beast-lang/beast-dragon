module beast.code.ast.decl.declaration;

import beast.code.ast.decl.toolkit;
import beast.code.ast.expr.unary;
import beast.code.ast.identifier;
import beast.code.ast.decl.variable;
import beast.code.ast.decl.function_;
import beast.code.ast.expr.auto_;

abstract class AST_Declaration : AST_Statement {

	public:
		static bool canParse( ) {
			return AST_DecorationList.canParse || AST_UnaryExpression.canParse;
		}

		static AST_Declaration parse( AST_DecorationList parentDecorationList ) {
			auto _gd = codeLocationGuard( );
			AST_DecorationList decorationList = parentDecorationList;

			// Decoration list
			if ( AST_DecorationList.canParse ) {
				decorationList = AST_DecorationList.parse( );
				decorationList.parentDecorationList = parentDecorationList;
			}

			return parse( _gd, decorationList );
		}

		static AST_Declaration parse( CodeLocationGuard _gd, AST_DecorationList decorationList ) {
			/// Type of variable or return type of a function
			AST_Expression type = AST_UnaryExpression.parse( );

			return parse( _gd, decorationList, type );
		}

		static AST_Declaration parse( CodeLocationGuard _gd, AST_DecorationList decorationList, AST_Expression type ) {
			/// Identifier
			AST_Identifier identifier = AST_Identifier.parse( );

			// And now we decide, if it is a function or not

			// ";" || "=" => variable
			if ( currentToken == Token.Special.semicolon || currentToken == Token.Operator.assign || currentToken == Token.Operator.colonAssign )
				return AST_VariableDeclaration.parse( _gd, decorationList, type, identifier );

			// "(" => function
			else if ( currentToken == Token.Special.lParent )
				return AST_FunctionDeclaration.parse( _gd, decorationList, type, identifier );

			currentToken.reportSyntaxError( "';', '=' or ':=' for variable declaration or parameter list for function declaration" );
			assert( 0 );
		}

	public:
		/// Processes the declaration, resulting in a symbol(s) - so module level declaration
		/// For each symbol created, calls the function sink
		abstract void executeDeclarations( DeclarationEnvironment env, void delegate( Symbol ) sink );

	public:
		AST_DecorationList decorationList;

}
