module beast.code.ast.expr.new_;

import beast.code.ast.toolkit;
import beast.code.ast.expr.prefix;
import beast.code.ast.expr.binary;
import beast.code.ast.expr.parentcomma;
import beast.code.data.util.reinterpret;

final class AST_NewExpression : AST_Expression {
	alias LowerLevelExpression = AST_PrefixExpression;

	public:
		static bool canParse( ) {
			return LowerLevelExpression.canParse || currentToken == Token.Keyword.new_;
		}

		static AST_Expression parse( ) {
			auto _gd = codeLocationGuard( );

			if ( currentToken.matchAndNext( Token.Keyword.new_ ) ) {
				auto result = new AST_NewExpression;

				auto data = LowerLevelExpression.parse().asNewRightExpression( );
				result.type = data[ 0 ];
				result.args = data[ 1 ];

				return result;
			}

			return LowerLevelExpression.parse( );
		}

	public:
		AST_Expression type;
		AST_ParentCommaExpression args;

	public:
		override Overloadset buildSemanticTree( Symbol_Type inferredType, bool errorOnInferrationFailure = true ) {
			const auto __gd = ErrorGuard( codeLocation );

			Symbol_Type ttype = type.ctExec( coreType.Type ).readType( );
			Symbol_Type refType = coreType.Reference.referenceTypeOf( ttype );

			DataEntity mallocCall = coreFunc.malloc.dataEntity.resolveCall( this, true, ttype.instanceSizeLiteral );
			DataEntity ctorCall = new DataEntity_ReinterpretCast( mallocCall, refType ).expectResolveIdentifier( ID!"#ctor" ).resolveCall( args, true, args.items );

			return ctorCall.Overloadset;
		}

	protected:
		override SubnodesRange _subnodes( ) {
			return nodeRange( type, args );
		}

}
