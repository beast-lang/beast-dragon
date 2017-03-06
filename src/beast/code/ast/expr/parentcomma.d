module beast.code.ast.expr.parentcomma;

import beast.code.ast.toolkit;
import beast.code.ast.expr.vardecl;
import beast.code.data.callable;

/// Parameter list used in declarations
final class AST_ParentCommaExpression : AST_Expression, AST_P1ExpressionItem {

	public:
		static bool canParse( ) {
			return currentToken == Token.Special.lParent;
		}

		static AST_ParentCommaExpression parse( ) {
			auto _gd = codeLocationGuard( );
			auto result = new AST_ParentCommaExpression( );

			currentToken.expectAndNext( Token.Special.lParent );

			if ( AST_Expression.canParse ) {
				result.items ~= AST_Expression.parse( );

				while ( currentToken.matchAndNext( Token.Special.comma ) )
					result.items ~= AST_Expression.parse( );

				currentToken.expectAndNext( Token.Special.rParent, "',' or ')' after expression" );
			}
			else
				currentToken.expectAndNext( Token.Special.rParent, "expression or ')'" );

			result.codeLocation = _gd.get( );
			return result;
		}

	public:
		AST_Expression[ ] items;

	public:
		/// Returns whether the parentcommaexpression could qualify as runtime parameter list
		final bool isRuntimeParameterList( ) {
			foreach ( expr; items ) {
				if ( AST_VariableDeclarationExpression decl = expr.isVariableDeclaration ) {
					// Auto expressions cannot be expanded
					if ( decl.dataType.isAutoExpression )
						return false;
				}
			}

			return true;
		}

	public:
		override Overloadset buildSemanticTree( Symbol_Type expectedType, DataScope scope_, bool errorOnInferrationFailure = true ) {
			const auto _gd = ErrorGuard( this );

			// Maybe replace with void?
			benforce( items.length > 0, E.syntaxError, "Empty parentheses" );

			// We're passing null as expectedType because expectedType only applies to the rightmost part of the expression
			DataEntity[ ] payload = items[ 0 .. $ - 1 ].map!( x => buildSemanticTree_single( null, scope_ ) ).array;
			DataEntity base = items[ $ - 1 ].buildSemanticTree_single( expectedType, scope_, errorOnInferrationFailure );

			if ( payload.length == 0 )
				return base.Overloadset;

			return new DataEntity_ParentComma( payload, base, this ).Overloadset;
		}

		override Overloadset p1expressionItem_buildSemanticTree( Overloadset leftSide, Symbol_Type expectedType, DataScope scope_ ) {
			const auto _gd = ErrorGuard( this );
			return leftSide.resolveCall( this, scope_ ).toDataEntity.Overloadset;
		}

	protected:
		override InputRange!AST_Node _subnodes( ) {
			return nodeRange( items );
		}

}

/// Data entity which executes additional code
final class DataEntity_ParentComma : DataEntity {

	public:
		this( DataEntity[ ] payload, DataEntity base, AST_ParentCommaExpression ast ) {
			payload_ = payload;
			base_ = base;
		}

	public:
		override Symbol_Type dataType( ) {
			return base_.dataType;
		}

		override DataEntity parent( ) {
			return base_;
		}

		override bool isCtime( ) {
			return base_.isCtime && payload_.all!( x => x.isCtime );
		}

		override bool isCallable( ) {
			return base_.isCallable;
		}

		override CallableMatch startCallMatch( DataScope scope_, AST_Node ast ) {
			return base_.startCallMatch( scope_, ast );
		}

	public:
		override string identification( ) {
			return "( %s )".format( ( payload_ ~ base_ ).map!( x => x.identificationString ).joiner( ", " ).to!string );
		}

		override AST_Node ast( ) {
			return ast_;
		}

	public:
		override void buildCode( CodeBuilder cb, DataScope scope_ ) {
			foreach ( pl; payload_ )
				pl.buildCode( cb, scope_ );

			base_.buildCode( cb, scope_ );
		}

	private:
		DataEntity[ ] payload_;
		DataEntity base_;
		AST_ParentCommaExpression ast_;

}
