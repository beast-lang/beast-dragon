module beast.code.ast.stmt.return_;

import beast.code.ast.toolkit;

final class AST_ReturnStatement : AST_Statement {

	public:
		pragma( inline ) static bool canParse( ) {
			return currentToken == Token.Keyword.return_;
		}

		/// Continues parsing after decoration list
		static AST_ReturnStatement parse( CodeLocationGuard _gd, AST_DecorationList decorationList ) {
			auto result = new AST_ReturnStatement;
			benforce( decorationList is null, E.invalidDecoration, "Decorating return statement is not allowed" );

			currentToken.expectAndNext( Token.Keyword.return_ );

			while ( AST_Expression.canParse )
				result.expression = AST_Expression.parse( );

			currentToken.expectAndNext( Token.Special.semicolon );

			result.codeLocation = _gd.get( );
			return result;
		}

	public:
		override void buildStatementCode( DeclarationEnvironment env, CodeBuilder cb ) {
			const auto __gd = ErrorGuard( codeLocation );

			DataEntity result;

			if ( expression ) {
				if( env.functionReturnType )
					result = expression.buildSemanticTree_singleExpect( env.functionReturnType );

				else {
					result = expression.buildSemanticTree_single();
					env.functionReturnType = result.dataType;
				}
			}
			else if ( !env.functionReturnType )
				env.functionReturnType = coreLibrary.type.Void;
			else
				benforce( env.functionReturnType is coreLibrary.type.Void, E.missingReturnExpression, "Missing return value of type '%s'".format( env.functionReturnType.identificationString ) );

			cb.build_return( result );
		}

	public:
		AST_Expression expression;

	protected:
		override SubnodesRange _subnodes( ) {
			// Decoration list can be inherited from decoration block or something, in that case we should not consider it a subnodes
			return nodeRange( expression );
		}

}
