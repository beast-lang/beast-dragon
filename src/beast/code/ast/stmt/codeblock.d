module beast.code.ast.stmt.codeblock;

import beast.code.ast.toolkit;
import beast.code.data.scope_.local;
import beast.code.decorationlist;
import beast.code.ast.stmt.statement;
import beast.backend.ctime.codebuilder;

final class AST_CodeBlockStatement : AST_Statement {

	public:
		pragma( inline ) static bool canParse( ) {
			return currentToken == Token.Special.lBrace;
		}

		pragma( inline ) static AST_CodeBlockStatement parse( ) {
			return parse( codeLocationGuard( ), null );
		}

		/// Continues parsing after decoration list
		static AST_CodeBlockStatement parse( CodeLocationGuard _gd, AST_DecorationList decorationList ) {
			auto result = new AST_CodeBlockStatement;
			result.decorationList = decorationList;

			currentToken.expectAndNext( Token.Special.lBrace );

			while ( AST_Statement.canParse )
				result.subStatements ~= AST_Statement.parse( null );

			currentToken.expectAndNext( Token.Special.rBrace, "statement or '}'" );

			result.codeLocation = _gd.get( );
			return result;
		}

	public:
		override void buildStatementCode( DeclarationEnvironment env, CodeBuilder cb ) {
			const auto __gd = ErrorGuard( codeLocation );

			auto decoList = scoped!DecorationList( decorationList );
			auto decoData = scoped!StatementDecorationData( );

			decoList.apply_statementDecorator( decoData );
			decoList.enforceAllResolved( );

			if ( decoData.isCtime ) {
				cb = new CodeBuilder_Ctime( );
				env = env.dup();
				env.isCtime = true;
			}

			cb.build_scope( ( cb ) {
				foreach ( stmt; subStatements ) {
					cb.build_comment( stmt.codeLocation.content );
					stmt.buildStatementCode( env, cb );
				}
			} ).inLocalDataScope;
		}

	public:
		AST_DecorationList decorationList;
		AST_Statement[ ] subStatements;

	protected:
		override SubnodesRange _subnodes( ) {
			// Decoration list can be inherited from decoration block or something, in that case we should not consider it a subnodes
			return nodeRange( subStatements, decorationList.codeLocation.isInside( codeLocation ) ? decorationList : null );
		}

}
