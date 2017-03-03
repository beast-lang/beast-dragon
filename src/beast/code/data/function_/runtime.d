module beast.code.data.function_.runtime;

import beast.code.data.toolkit;
import beast.code.data.function_.function_;
import beast.code.data.function_.expandedparameter;
import beast.code.ast.expr.expression;

/// Runtime function = function without @ctime arguments (or expanded ones)
abstract class Symbol_RuntimeFunction : Symbol_Function {

	public:
		abstract Symbol_Type returnType( );

		abstract ExpandedFunctionParameter[ ] parameters( );

	protected:
		abstract class Data : SymbolRelatedDataEntity {

			public:
				this( ) {
					super( this.outer );
				}

			public:
				override Symbol_Type dataType( ) {
					// TODO: Function types
					return coreLibrary.types.Void;
				}

				override bool isCtime( ) {
					// TODO: This might not true for member functions
					return true;
				}

				final override bool isCallable( ) {
					return true;
				}

				override string identification( ) {
					auto result = appender!string;
					result ~= identifier ? identifier.str : "(anonymous function)";
					result ~= "(";

					if ( parameters.length )
						result ~= " ";

					foreach ( i, param; parameters ) {
						if ( i )
							result ~= ", ";

						result ~= param.identificationString;
					}

					if ( parameters.length )
						result ~= " ";

					result ~= ")";
					return result.data;
				}

			public:
				override CallableMatch startCallMatch( DataScope scope_, AST_Node ast ) {
					return new Match( scope_, this, ast );
				}

		}

		final class Match : CallableMatch {

			public:
				this( DataScope scope_, DataEntity sourceEntity, AST_Node ast ) {
					super( scope_, sourceEntity, ast );
				}

			protected:
				override Level _matchNextArgument( AST_Expression expression, DataEntity entity, Symbol_Type dataType ) {
					if( argumentIndex_ >= parameters.length )
						return Level.noMatch;

					ExpandedFunctionParameter param = parameters[ argumentIndex_ ];

					/// If the expression needs expectedType to be parsed, parse it with current parameter type as expected
					if ( !entity ) {
						with ( memoryManager.session ) {
							entity = expression.buildSemanticTree_single( param.type, scope_ );
							dataType = entity.dataType;
						}
					}
					else // Add the entity to the scope so it is findable
						scope_.addEntity( entity );

					if ( dataType !is param.type )
						return Level.noMatch;

					if ( param.constValue ) {
						// TODO: This will have to be solved better -- or not?
						if ( !entity.isCtime )
							return Level.noMatch;

						MemoryPtr entityData = entity.ctExec( scope_ );
						if ( !entityData.dataEquals( param.constValue, dataType.instanceSize ) )
							return Level.noMatch;
					}

					arguments_ ~= entity;
					argumentIndex_++;

					return Level.fullMatch;
				}

				override Level _finish( ) {
					if ( argumentIndex_ != parameters.length )
						return Level.noMatch;

					return Level.fullMatch;
				}

				override DataEntity _toDataEntity( ) {
					return new MatchData( this );
				}

			private:
				Symbol_RuntimeFunction func_;
				DataEntity[ ] arguments_;
				size_t argumentIndex_;

		}

		final class MatchData : DataEntity {

			public:
				this( Match match ) {
					arguments_ = match.arguments_;
					ast_ = match.ast;
				}

			public:
				override Symbol_Type dataType( ) {
					return this.outer.returnType;
				}

				override bool isCtime( ) {
					// TODO:
					return false;
				}

				override string identification( ) {
					return "%s( %s )".format( this.outer.identificationString, arguments_.map!( x => x.identificationString ).joiner( ", " ).to!string );
				}

				override DataEntity parent( ) {
					return this.outer.dataEntity;
				}

				override AST_Node ast( ) {
					return ast_;
				}

			public:
				override void buildCode( CodeBuilder cb, DataScope scope_ ) {
					cb.build_functionCall( scope_, this.outer, arguments_ );
				}

			private:
				DataEntity[ ] arguments_;
				AST_Node ast_;

		}

}
