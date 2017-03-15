/// RunTime
module beast.code.data.function_.rt;

import beast.code.data.function_.toolkit;
import beast.backend.interpreter.codeblock;
import beast.backend.interpreter.codebuilder;

/// Runtime function = function without @ctime arguments (or expanded ones)
abstract class Symbol_RuntimeFunction : Symbol_Function {
	mixin TaskGuard!"codeProcessing";

	protected:
		this( ) {

		}

	public:
		abstract Symbol_Type returnType( );

		abstract ExpandedFunctionParameter[ ] parameters( );

	protected:
		override void execute_outerHashObtaining( ) {
			super.execute_outerHashObtaining( );

			foreach ( param; parameters )
				outerHashWIP_ += param.dataType.outerHash;
		}

		final void execute_codeProcessing( ) {
			auto cb = scoped!CodeBuilder_Interpreter( );
			buildDefinitionsCode( cb );
			interpreterCodeWIP_ = cb.result;
		}

		final string baseIdentifier( ) {
			return identifier ? identifier.str : "(anonymous function)";
		}

	private:
		InterpreterCodeBlock interpreterCodeWIP_;

	protected:
		abstract static class Data : SymbolRelatedDataEntity {

			public:
				this( Symbol_RuntimeFunction sym ) {
					super( sym );
					sym_ = sym;
				}

			public:
				override Symbol_Type dataType( ) {
					// TODO: Function types
					return coreLibrary.type.Void;
				}

				override bool isCtime( ) {
					// TODO: This might not true for member functions
					return true;
				}

				final override bool isCallable( ) {
					return true;
				}

				override string identificationString( ) {
					if ( this is null )
						return "#error#";

					return "%s %s.%s( %s )".format( sym_.returnType ? sym_.returnType.identificationString : "#error", parent.identificationString, sym_.baseIdentifier, sym_.parameters.map!( x => x.identificationString ).joiner( ", " ) );
				}

			public:
				override CallableMatch startCallMatch( DataScope scope_, AST_Node ast ) {
					return new Match( sym_, scope_, this, ast );
				}

			private:
				Symbol_RuntimeFunction sym_;

		}

		static class Match : SeriousCallableMatch {

			public:
				this( Symbol_RuntimeFunction sym, DataScope scope_, DataEntity sourceEntity, AST_Node ast ) {
					super( scope_, sourceEntity, ast );
					sym_ = sym;
				}

			protected:
				override MatchFlags _matchNextArgument( AST_Expression expression, DataEntity entity, Symbol_Type dataType ) {
					if ( argumentIndex_ >= sym_.parameters.length ) {
						errorStr = "parameter count mismatch";
						return MatchFlags.noMatch;
					}

					ExpandedFunctionParameter param = sym_.parameters[ argumentIndex_ ];

					/// If the expression needs expectedType to be parsed, parse it with current parameter type as expected
					if ( !entity ) {
						with ( memoryManager.session ) {
							entity = expression.buildSemanticTree_single( param.dataType, scope_ );
							dataType = entity.dataType;
						}
					}

					if ( dataType !is param.dataType ) {
						errorStr = "argument %s type mismatch (got %s, expected %s)".format( argumentIndex_, dataType.identificationString, param.dataType.identificationString );
						return MatchFlags.noMatch;
					}

					if ( param.constValue ) {
						// TODO: This will have to be solved better -- or not?
						if ( !entity.isCtime ) {
							errorStr = "argument %s not ctime, cannot compare".format( argumentIndex_ );
							return MatchFlags.noMatch;
						}

						MemoryPtr entityData = entity.ctExec( scope_ );
						if ( !entityData.dataEquals( param.constValue, dataType.instanceSize ) ) {
							errorStr = "argument %s value mismatch".format( argumentIndex_ );
							return MatchFlags.noMatch;
						}

					}

					arguments_ ~= entity;
					argumentIndex_++;

					return MatchFlags.fullMatch;
				}

				override MatchFlags _finish( ) {
					if ( argumentIndex_ != sym_.parameters.length ) {
						errorStr = "parameter count mismatch";
						return MatchFlags.noMatch;
					}

					return MatchFlags.fullMatch | super._finish( );
				}

				override DataEntity _toDataEntity( ) {
					return new MatchData( sym_, this );
				}

			private:
				Symbol_RuntimeFunction sym_;
				DataEntity[ ] arguments_;
				size_t argumentIndex_;

		}

		static class MatchData : DataEntity {

			public:
				this( Symbol_RuntimeFunction sym, Match match ) {
					arguments_ = match.arguments_;
					ast_ = match.ast;
					sym_ = sym;
				}

			public:
				override Symbol_Type dataType( ) {
					return sym_.returnType;
				}

				override bool isCtime( ) {
					// TODO: ctime deduction (long-time target)
					return false;
				}

				override string identificationString( ) {
					if ( this is null )
						return "#error#";

					return "%s %s.%s( ... )( %s )".format( sym_.returnType.identificationString, parent.identificationString, sym_.baseIdentifier, arguments_.map!( x => x.identificationString ).joiner( ", " ).to!string );
				}

				override DataEntity parent( ) {
					return sym_.dataEntity.parent;
				}

				override AST_Node ast( ) {
					return ast_;
				}

			public:
				override void buildCode( CodeBuilder cb, DataScope scope_ ) {
					const auto _gd = ErrorGuard( ast_ );
					cb.build_functionCall( scope_, sym_, null, arguments_ );
				}

			protected:
				DataEntity[ ] arguments_;
				AST_Node ast_;
				Symbol_RuntimeFunction sym_;

		}

}
