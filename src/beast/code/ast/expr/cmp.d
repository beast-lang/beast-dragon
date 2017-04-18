module beast.code.ast.expr.cmp;

import beast.code.ast.toolkit;
import beast.code.ast.expr.sum;
import beast.code.ast.expr.binary;
import std.range : chain;
import beast.code.data.var.btspconst;
import beast.code.data.symbol;
import beast.code.data.matchlevel;
import beast.code.data.var.tmplocal;

final class AST_CmpExpression : AST_Expression {
	alias LowerLevelExpression = AST_SumExpression;

	public:
		static bool canParse( ) {
			return LowerLevelExpression.canParse;
		}

		static AST_Expression parse( ) {
			auto _gd = codeLocationGuard( );

			AST_Expression base = LowerLevelExpression.parse( );

			if ( !isCmpOperator( currentToken ) )
				return base;

			auto result = new AST_CmpExpression;
			result.base = base;

			CmpOperatorGroups groups = cmpOperatorGroups( currentToken.operator );
			while ( isCmpOperator( currentToken ) ) {
				Item item;
				item.op = currentToken.operator;

				groups &= cmpOperatorGroups( item.op );
				benforce( groups != 0 || result.items.length == 0, E.invalidOpCombination, //
						"Cannot combine comparison operators %s".format( chain( result.items.map!( x => x.op ), [ item.op ] ).map!( x => "'%s'".format( Token.operatorStr[ cast( int ) x ] ) ).joiner( ", " ) ), //
						( err ) { err.codeLocation = _gd.get( ); } );

				getNextToken( );
				item.expr = LowerLevelExpression.parse( );

				result.items ~= item;
			}

			result.codeLocation = _gd.get( );
			return result;
		}

	public:
		AST_Expression base;
		Item[ ] items;

	public:
		struct Item {
			Token.Operator op;
			AST_Expression expr;
		}

	public:
		override Overloadset buildSemanticTree( Symbol_Type inferredType, bool errorOnInferrationFailure = true ) {
			const auto __gd = ErrorGuard( codeLocation );

			DataEntity baseOperand = base.buildSemanticTree_singleInfer( inferredType, errorOnInferrationFailure );

			DataEntity leftOperand = baseOperand;
			DataEntity result = null;

			// If errorOnInferrationFailure is false then result might be null (inferration failure)
			if ( !baseOperand )
				return Overloadset( );

			auto binAnd = coreLibrary.enum_.operator.binAnd.dataEntity;

			foreach ( item; items[ 0 .. $ - 1 ] ) {
				DataEntity rightExpr = item.expr.buildSemanticTree_single( );
				auto var = new DataEntity_TmpLocalVariable( rightExpr.dataType, rightExpr.isCtime );
				auto varCtor = var.getCopyCtor( rightExpr );

				auto cmpResult = resolveBinaryOperation( item.expr, leftOperand, var, cmpOperatorEnumConst( item.op ).dataEntity, item.op );
				auto data = new Data( this, leftOperand, var, varCtor, cmpResult );

				if ( result )
					result = resolveBinaryOperation( item.expr, result, data, binAnd, Token.Operator.logAnd );
				else
					result = data;

				leftOperand = var;
			}

			// We don't need to save last operand to a variable
			{
				auto item = items[ $ - 1 ];

				DataEntity rightExpr = item.expr.buildSemanticTree_single( );
				auto cmpResult = resolveBinaryOperation( item.expr, leftOperand, rightExpr, cmpOperatorEnumConst( item.op ).dataEntity, item.op );

				if( result )
					result = resolveBinaryOperation( item.expr, result, cmpResult, binAnd, Token.Operator.logAnd );
				else
					result = cmpResult;
			}

			return result.Overloadset;
		}

	protected:
		override SubnodesRange _subnodes( ) {
			return nodeRange( base, items.map!( x => x.expr ) );
		}

	protected:
		pragma( inline ) static bool isCmpOperator( Token token ) {
			return token == Token.Operator.less || token == Token.Operator.lessEquals //
			 || token == Token.Operator.equals || token == Token.Operator.notEquals //
			 || token == Token.Operator.greater || token == Token.Operator.greaterEquals;
		}

		pragma( inline ) static CmpOperatorGroups cmpOperatorGroups( Token.Operator op ) {
			switch ( op ) {

			case Token.Operator.equals:
				return CmpOperatorGroups.ascending | CmpOperatorGroups.descending;

			case Token.Operator.notEquals:
				return CmpOperatorGroups.none;

			case Token.Operator.less:
			case Token.Operator.lessEquals:
				return CmpOperatorGroups.ascending;

			case Token.Operator.greater:
			case Token.Operator.greaterEquals:
				return CmpOperatorGroups.descending;

			default:
				assert( 0 );

			}
		}

		pragma( inline ) static Symbol_BootstrapConstant cmpOperatorEnumConst( Token.Operator op ) {
			switch ( op ) {

			case Token.Operator.equals:
				return coreLibrary.enum_.operator.binEq;

			case Token.Operator.notEquals:
				return coreLibrary.enum_.operator.binNeq;

			case Token.Operator.less:
				return coreLibrary.enum_.operator.binLt;

			case Token.Operator.lessEquals:
				return coreLibrary.enum_.operator.binLte;

			case Token.Operator.greater:
				return coreLibrary.enum_.operator.binGt;

			case Token.Operator.greaterEquals:
				return coreLibrary.enum_.operator.binGte;

			default:
				assert( 0 );

			}
		}

	protected:
		enum CmpOperatorGroups {
			none = 0,
			ascending = 1, // < <= ==
			descending = ascending << 1 // > >= ==
		}

		final class Data : DataEntity {

			public:
				this( AST_CmpExpression ast, DataEntity leftOperand, DataEntity_TmpLocalVariable operandVar, DataEntity operandCtor, DataEntity cmpFunctionResult ) {
					super( MatchLevel.fullMatch );
					ast_ = ast;
					operandVar_ = operandVar;
					operandCtor_ = operandCtor;
					cmpFunctionResult_ = cmpFunctionResult;
					leftOperand_ = leftOperand;
				}

			public:
				override Symbol_Type dataType( ) {
					return cmpFunctionResult_.dataType;
				}

				override DataEntity parent( ) {
					return leftOperand_;
				}

				override bool isCtime( ) {
					return cmpFunctionResult_.isCtime;
				}

				override AST_Node ast( ) {
					return ast_;
				}

			protected:
				override void buildCode( CodeBuilder cb ) {
					auto _gd = ErrorGuard( ast_.codeLocation );

					// Define the variable
					cb.build_localVariableDefinition( operandVar_ );

					// Call the constructor
					operandCtor_.buildCode( cb );

					// Call the comparison function
					cmpFunctionResult_.buildCode( cb );
				}

			private:
				AST_CmpExpression ast_;
				DataEntity_TmpLocalVariable operandVar_;
				DataEntity operandCtor_, cmpFunctionResult_, leftOperand_;

		}

}
