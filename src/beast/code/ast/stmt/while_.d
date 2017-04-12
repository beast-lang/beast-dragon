module beast.code.ast.stmt.while_;

import beast.code.ast.toolkit;

final class AST_WhileStatement : AST_Statement {

	public:
		pragma( inline ) static bool canParse( ) {
			return currentToken == Token.Keyword.while_;
		}

		/// Continues parsing after decoration list
		static AST_WhileStatement parse( CodeLocationGuard _gd, AST_DecorationList decorationList ) {
			auto result = new AST_WhileStatement;
			benforce( decorationList is null, E.invalidDecoration, "Decorating a while statement is not allowed" );

			currentToken.expectAndNext( Token.Keyword.while_ );

			// Condition
			{
				currentToken.expectAndNext( Token.Special.lParent );
				result.condition = AST_Expression.parse( );
				currentToken.expectAndNext( Token.Special.rParent );
			}

			result.body_ = AST_Statement.parse( null );

			result.codeLocation = _gd.get( );
			return result;
		}

	public:
		override void buildStatementCode( DeclarationEnvironment env, CodeBuilder cb ) {
			const auto __gd = ErrorGuard( codeLocation );

			cb.build_loop( ( CodeBuilder cb ) { //
				cb.build_if(  //
					condition.buildSemanticTree_singleExpect( coreType.Bool ).expectResolveIdentifier( ID!"#opPrefix" ).resolveCall( condition, true, coreLibrary.enum_.operator.preNot ), //
					( CodeBuilder cb ) { //
						cb.build_break( );
					}, null );

				body_.buildStatementCode( env, cb );
			} );
		}

	public:
		AST_Expression condition;
		AST_Statement body_;

	protected:
		override SubnodesRange _subnodes( ) {
			// Decoration list can be inherited from decoration block or something, in that case we should not consider it a subnodes
			return nodeRange( condition, body_ );
		}

}
