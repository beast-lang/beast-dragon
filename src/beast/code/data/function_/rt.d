/// RunTime
module beast.code.data.function_.rt;

import beast.code.data.function_.toolkit;
import beast.backend.interpreter.codeblock;
import beast.backend.interpreter.codebuilder;
import beast.code.data.codenamespace.bootstrap;
import beast.code.data.codenamespace.namespace;
import beast.code.data.util.proxy;
import beast.code.ast.decl.env;

//debug = interpreter;

/// Runtime function = function without @ctime arguments (or expanded ones)
abstract class Symbol_RuntimeFunction : Symbol_Function {
	mixin TaskGuard!"codeProcessing";

	public:
		this( ) {
			taskManager.delayedIssueJob( { project.backend.buildRuntimeFunction( this ); } );
		}

	public:
		abstract Symbol_Type returnType( );

		/// Type of required contextPtr (null for static functions)
		abstract Symbol_Type contextType();

		abstract ExpandedFunctionParameter[ ] parameters( );

		final InterpreterCodeBlock interpreterCode( ) {
			enforceDone_codeProcessing( );
			return codeProcessingCodeBuilderWIP_.result;
		}

	public:
		final void buildCode( CodeBuilder cb ) {
			// Enforce return type deduction
			returnType( );

			// We also need staticMemberMerger
			// TODO: make staticMemberMerger asynchronous so this is not necessary (also we need to synchronize error reporting so we don't get two same errors from the same code)
			enforceDone_codeProcessing( );

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

			debug ( interpreter )
				codeProcessingCodeBuilderWIP_.debugPrintResult( identificationString );
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
				this( Symbol_RuntimeFunction sym, MatchLevel matchLevel ) {
					super( sym, matchLevel );
					sym_ = sym;
				}

			public:
				override Symbol_Type dataType( ) {
					// TODO: Function types
					return coreType.Void;
				}

				override bool isCtime( ) {
					// TODO: This might not true for member functions
					return true;
				}

				final override bool isCallable( ) {
					return true;
				}

				override string identification( ) {
					return "%s( %s )".format( sym_.baseIdentifier, sym_.parameters.map!( x => x.tryGetIdentificationString ).joiner( ", " ) );
				}

				override string identificationString( ) {
					return "%s %s".format( sym_.returnType.tryGetIdentificationString, identificationString_noPrefix );
				}

			public:
				override CallableMatch startCallMatch( AST_Node ast, bool canThrowErrors, MatchLevel matchLevel ) {
					return new Match( sym_, this, null, ast, canThrowErrors, this.matchLevel | matchLevel );
				}

			protected:
				override Overloadset _resolveIdentifier_pre( Identifier id, MatchLevel matchLevel ) {
					if ( id == ID!"#returnType" )
						return sym_.returnType.dataEntity( matchLevel ).Overloadset;

					return Overloadset( );
				}

			private:
				Symbol_RuntimeFunction sym_;

		}

		static class Match : SeriousCallableMatch {

			public:
				this( Symbol_RuntimeFunction sym, DataEntity sourceEntity, DataEntity parentInstance, AST_Node ast, bool canThrowErrors, MatchLevel matchLevel ) {
					super( sourceEntity, ast, canThrowErrors, matchLevel );
					sym_ = sym;
					sourceEntity_ = sourceEntity;
					parentInstance_ = parentInstance;
				}

			protected:
				override MatchLevel _matchNextArgument( AST_Expression expression, DataEntity entity, Symbol_Type dataType ) {
					auto _sgd = scope_.scopeGuard( false );
					MatchLevel result = MatchLevel.fullMatch;

					if ( argumentIndex_ >= sym_.parameters.length ) {
						errorStr = "too many arguments";
						return MatchLevel.noMatch;
					}

					ExpandedFunctionParameter param = sym_.parameters[ argumentIndex_ ];

					if ( param.constValue )
						result |= matchConstValue( expression, entity, dataType, param.dataType, param.constValue );
					else
						result |= matchStandardArgument( expression, entity, dataType, param.dataType );

					if ( result == MatchLevel.noMatch )
						return MatchLevel.noMatch;

					arguments_ ~= entity;

					return result;
				}

				override MatchLevel _finish( ) {
					if ( argumentIndex_ != sym_.parameters.length ) {
						errorStr = "not enough arguments";
						return MatchLevel.noMatch;
					}

					return MatchLevel.fullMatch | super._finish( );
				}

				override DataEntity _toDataEntity( ) {
					return new MatchData( sym_, this );
				}

			protected:
				Symbol_RuntimeFunction sym_;
				DataEntity[ ] arguments_;
				DataEntity sourceEntity_, parentInstance_;

		}

		static class MatchData : DataEntity {

			public:
				this( Symbol_RuntimeFunction sym, Match match ) {
					super( match.matchLevel );
					arguments_ = match.arguments_;
					ast_ = match.ast;
					sym_ = sym;
					parentInstance_ = match.parentInstance_;
				}

			public:
				final override Symbol_Type dataType( ) {
					return sym_.returnType;
				}

				override bool isCtime( ) {
					// TODO: ctime deduction (long-time target)
					return false;
				}

				/*override string identification( ) {
					return "%s( ... )( %s )".format( sym_.baseIdentifier, arguments_.map!( x => x.tryGetIdentificationString ).joiner( ", " ).to!string );
				}*/

				final override string identificationString( ) {
					//return "%s %s".format( sym_.returnType.tryGetIdentificationString, super.identificationString );
					return "%s call".format( sym_.dataEntity( MatchLevel.fullMatch, parentInstance_ ).identificationString );
				}

				final override DataEntity parent( ) {
					return sym_.dataEntity.parent;
				}

				final override AST_Node ast( ) {
					return ast_;
				}

			public:
				override void buildCode( CodeBuilder cb ) {
					const auto _gd = ErrorGuard( codeLocation );
					cb.build_functionCall( sym_, parentInstance_, arguments_ );
				}

			protected:
				DataEntity[ ] arguments_;
				DataEntity parentInstance_;
				AST_Node ast_;
				Symbol_RuntimeFunction sym_;
		}

}
