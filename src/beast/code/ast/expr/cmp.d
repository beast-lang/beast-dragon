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

			// Now building semantic tree for this requires rather complicated approach - as we are subsituting results with temporary variables (we have to do that in buildCode :/)
			DataEntity baseOperand = base.buildSemanticTree_singleInfer( inferredType, errorOnInferrationFailure );

			DataEntity leftOperand = baseOperand;
			DataEntity result = null;
			ProcessedItem[ ] pitems;

			// If errorOnInferrationFailure is false then result might be null (inferration failure)
			if ( !baseOperand )
				return Overloadset( );

			auto binAnd = coreLibrary.enum_.operator.binAnd.dataEntity;

			foreach ( item; items ) {
				ProcessedItem pitem;
				pitem.operand = item.expr.buildSemanticTree_single( );
				pitem.operandCtor = pitem.operand.expectResolveIdentifier( ID!"#ctor" ).resolveCall( item.expr, true, pitem.operand ).symbol;
				pitem.cmpFunction = prepareResolveBinaryOperation( item.expr, leftOperand, pitem.operand, cmpOperatorEnumConst( item.op ).dataEntity, item.op );

				assert( pitem.operandCtor );

				DataEntity tmpCmpFunction = pitem.cmpFunction( leftOperand, pitem.operand );
				if ( result ) {
					pitem.andFunction = prepareResolveBinaryOperation( item.expr, result, tmpCmpFunction, binAnd, Token.Operator.logAnd );
					result = pitem.andFunction( result, tmpCmpFunction );
					pitem.dataType = result.dataType;
				}
				else
					result = tmpCmpFunction;

				pitems ~= pitem;
				leftOperand = pitem.operand;
			}

			return new Data( this, baseOperand, pitems, result.dataType, result.isCtime ).Overloadset;
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

		struct ProcessedItem {
			DataEntity operand;
			Symbol operandCtor;
			Symbol_Type dataType;
			DataEntity delegate( DataEntity, DataEntity ) cmpFunction, andFunction;
		}

		final class Data : DataEntity {

			public:
				this( AST_CmpExpression ast, DataEntity baseOperand, ProcessedItem[ ] processedItems, Symbol_Type dataType, bool isCtime ) {
					super( MatchLevel.fullMatch );
					ast_ = ast;
					baseOperand_ = baseOperand;
					processedItems_ = processedItems;
					dataType_ = dataType;
					isCtime_ = isCtime;
				}

			public:
				override Symbol_Type dataType( ) {
					return dataType_;
				}

				override DataEntity parent( ) {
					return baseOperand_;
				}

				override bool isCtime( ) {
					return isCtime_;
				}

				override AST_Node ast( ) {
					return ast_;
				}

			public:
				override void buildCode( CodeBuilder cb ) {
					auto _gd = ErrorGuard( ast_.codeLocation );

					DataEntity leftOperand = baseOperand_;
					DataEntity result = null;

					auto item = processedItems_[ 0 ];

					assert( processedItems_.length );
					if ( processedItems_.length == 1 )
						item.cmpFunction( leftOperand, item.operand ).buildCode( cb );

					else {
						auto item2 = processedItems_[ 1 ];

						auto var = new DataEntity_TmpLocalVariable( item.operand.dataType, cb.isCtime );
						cb.build_localVariableDefinition( var );
						item.operandCtor.dataEntity( MatchLevel.fullMatch, var ).resolveCall( item.operand.ast, true, item.operand ).buildCode( cb );

						item2.andFunction( item.cmpFunction( leftOperand, var ), new Data( ast_, var, processedItems_[ 1 .. $ ], item2.dataType, isCtime ) ).buildCode( cb );
					}
					/*
					foreach ( item; processedItems_[ 0 .. $ - 1 ] ) {
						auto var = new DataEntity_TmpLocalVariable( item.operand.dataType, cb.isCtime );
						cb.build_localVariableDefinition( var );

						// We have pre-resolved ctor from the buildSemanticTree
						item.operandCtor.dataEntity( MatchLevel.fullMatch, var ).startCallMatch( item.operand.ast, true, MatchLevel.fullMatch ).arg( coreLibrary.enum_.xxctor.assign.dataEntity ).arg( item.operand ).finish( ).toDataEntity( ).buildCode( cb );

						DataEntity cmpResult = item.cmpFunction( leftOperand, var );
						result = result ? item.andFunction( result, cmpResult ) : cmpResult;

						leftOperand = var;
					}

					// We don't need to save last right operand to a tmp variable
					{
						auto item = processedItems_[ $ - 1 ];
						DataEntity cmpResult = item.cmpFunction( leftOperand, item.operand );
						result = result ? item.andFunction( result, cmpResult ) : cmpResult;
					}

					assert( result );
					result.buildCode( cb );*/
				}

			private:
				Symbol_Type dataType_;
				bool isCtime_;
				AST_CmpExpression ast_;
				DataEntity baseOperand_;
				ProcessedItem[ ] processedItems_;

		}

}
