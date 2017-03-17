/// RunTime
module beast.code.data.function_.rt;

import beast.code.data.function_.toolkit;
import beast.backend.interpreter.codeblock;
import beast.backend.interpreter.codebuilder;
import beast.code.data.codenamespace.bootstrap;
import beast.code.data.codenamespace.namespace;
import beast.code.data.util.proxy;
import beast.code.ast.decl.env;

/// Runtime function = function without @ctime arguments (or expanded ones)
abstract class Symbol_RuntimeFunction : Symbol_Function {
	mixin TaskGuard!"codeProcessing";

	public:
		abstract Symbol_Type returnType( );

		abstract ExpandedFunctionParameter[ ] parameters( );

	public:
		final override void buildDefinitionsCode( CodeBuilder cb ) {
			// Enforce return type deduction
			returnType( );

			buildDefinitionsCode( cb, staticMembersMergerWIP_ );
		}

	protected:
		abstract void buildDefinitionsCode( CodeBuilder cb, StaticMemberMerger staticMemberMerger );

	protected:
		override void execute_outerHashObtaining( ) {
			super.execute_outerHashObtaining( );

			foreach ( param; parameters )
				outerHashWIP_ += param.outerHash;
		}

		final void execute_codeProcessing( ) {
			codeProcessingCodeBuilderWIP_ = new CodeBuilder_Interpreter( );
			staticMembersMergerWIP_ = new StaticMemberMerger;

			buildDefinitionsCode( codeProcessingCodeBuilderWIP_, staticMembersMergerWIP_ );

			staticMembersMergerWIP_.finish( );

			// codeProcessingCodeBuilderWIP_.debugPrintResult( identificationString );
		}

		final string baseIdentifier( ) {
			return identifier ? identifier.str : "(anonymous function)";
		}

	private:
		CodeBuilder_Interpreter codeProcessingCodeBuilderWIP_;
		/// Used for merging static members
		StaticMemberMerger staticMembersMergerWIP_;
		/// Namespace storing static members
		BootstrapNamespace internalNamespaceWIP_;

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

				override string identification( ) {
					return "%s( %s )".format( sym_.baseIdentifier, sym_.parameters.map!( x => x.identificationString ).joiner( ", " ) );
				}

			public:
				override CallableMatch startCallMatch( AST_Node ast ) {
					return new Match( sym_, this, ast );
				}

			protected:
				override Overloadset _resolveIdentifier_pre( Identifier id ) {
					if ( id == ID!"#returnType" )
						return sym_.returnType.dataEntity.Overloadset;

					return Overloadset( );
				}

			private:
				Symbol_RuntimeFunction sym_;

		}

		static class Match : SeriousCallableMatch {

			public:
				this( Symbol_RuntimeFunction sym, DataEntity sourceEntity, AST_Node ast ) {
					super( sourceEntity, ast );
					sym_ = sym;
				}

			protected:
				override MatchFlags _matchNextArgument( AST_Expression expression, DataEntity entity, Symbol_Type dataType ) {
					auto _sgd = scope_.scopeGuard;

					if ( argumentIndex_ >= sym_.parameters.length ) {
						errorStr = "parameter count mismatch";
						return MatchFlags.noMatch;
					}

					ExpandedFunctionParameter param = sym_.parameters[ argumentIndex_ ];

					/// If the expression needs expectedType to be parsed, parse it with current parameter type as expected
					if ( !entity ) {
						with ( memoryManager.session ) {
							entity = expression.buildSemanticTree_singleExpect( param.dataType );
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

						MemoryPtr entityData = entity.ctExec( );
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

				/*override string identification( ) {
					return "%s( ... )( %s )".format( sym_.baseIdentifier, arguments_.map!( x => x.tryGetIdentificationString ).joiner( ", " ).to!string );
				}*/

				override string identificationString( ) {
					//return "%s %s".format( sym_.returnType.tryGetIdentificationString, super.identificationString );
					return "%s (expression)".format( sym_.returnType.tryGetIdentificationString );
				}

				override DataEntity parent( ) {
					return sym_.dataEntity.parent;
				}

				override AST_Node ast( ) {
					return ast_;
				}

			public:
				override void buildCode( CodeBuilder cb ) {
					const auto _gd = ErrorGuard( ast_ );
					cb.build_functionCall( sym_, null, arguments_ );
				}

			protected:
				DataEntity[ ] arguments_;
				AST_Node ast_;
				Symbol_RuntimeFunction sym_;

		}

}
