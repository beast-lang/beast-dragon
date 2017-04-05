/// PRIMitive MEMber RunTime
module beast.code.data.function_.primmemrt;

import beast.code.data.function_.toolkit;
import beast.code.ast.decl.env;
import beast.code.data.var.local;
import beast.backend.common.primitiveop;
import beast.code.data.var.btspconst;
import beast.code.data.var.tmplocal;

/// Primitive (compiler-defined, handled by backend) member (non-static) runtime (non-templated) function
/// Calling primitive functions doesn't result in funciton call - given code is injected directly (like inline)
final class Symbol_PrimitiveMemberRuntimeFunction : Symbol_RuntimeFunction {

	public:
		alias PrimitiveFunc = void delegate( CodeBuilder cb, DataEntity instance, DataEntity[ ] arguments );

	public:
		this( Identifier identifier, Symbol_Type parent, Symbol_Type returnType, ExpandedFunctionParameter[ ] parameters, PrimitiveFunc func ) {
			staticData_ = new Data( this, null, MatchLevel.fullMatch );

			identifier_ = identifier;
			parent_ = parent;
			returnType_ = returnType;
			parameters_ = parameters;
			func_ = func;
		}

		override Identifier identifier( ) {
			return identifier_;
		}

		override Symbol_Type returnType( ) {
			return returnType_;
		}

		override ExpandedFunctionParameter[ ] parameters( ) {
			return parameters_;
		}

		override DeclType declarationType( ) {
			return DeclType.memberFunction;
		}

	public:
		override DataEntity dataEntity( MatchLevel matchLevel = MatchLevel.fullMatch, DataEntity parentInstance = null ) {
			if ( parentInstance || matchLevel != MatchLevel.fullMatch )
				return new Data( this, parentInstance, matchLevel );
			else
				return staticData_;
		}

	protected:
		override void buildDefinitionsCode( CodeBuilder cb, StaticMemberMerger staticMemberMerger ) {
			// Do nothing
		}

	private:
		Identifier identifier_;
		Symbol_Type parent_;
		Symbol_Type returnType_;
		Data staticData_;
		ExpandedFunctionParameter[ ] parameters_;
		PrimitiveFunc func_;

	public:
		/// Returns constructor that zeroes the instance memory
		static Symbol newPrimitiveCtor( Symbol_Type tp ) {
			return new Symbol_PrimitiveMemberRuntimeFunction( ID!"#ctor", tp, coreLibrary.type.Void, //
					ExpandedFunctionParameter.bootstrap( ), //
					( cb, inst, args ) { //
						cb.build_primitiveOperation( BackendPrimitiveOperation.memZero, inst );
					} );
		}

		/// Returns copy constructor that copies all data from the source instance
		static Symbol newPrimitiveCopyCtor( Symbol_Type tp ) {
			return new Symbol_PrimitiveMemberRuntimeFunction( ID!"#ctor", tp, coreLibrary.type.Void, //
					ExpandedFunctionParameter.bootstrap( coreLibrary.enum_.xxctor.opAssign, tp ), //
					( cb, inst, args ) { //
						// 0th arguments is #Ctor.opAssign!
						cb.build_primitiveOperation( BackendPrimitiveOperation.memCpy, inst, args[ 1 ] );
					} );
		}

		/// Returns destructor that does nothing
		static Symbol newNoopDtor( Symbol_Type tp ) {
			return new Symbol_PrimitiveMemberRuntimeFunction( ID!"#dtor", tp, coreLibrary.type.Void, //
					ExpandedFunctionParameter.bootstrap( ), //
					( cb, inst, args ) { //
						cb.build_primitiveOperation( BackendPrimitiveOperation.noopDtor, inst );
					} );
		}

		/// Returns assign operator that does a bit copy
		static Symbol newPrimitiveAssignOp( Symbol_Type tp ) {
			return new Symbol_PrimitiveMemberRuntimeFunction( ID!"#opAssign", tp, coreLibrary.type.Void, //
					ExpandedFunctionParameter.bootstrap( coreLibrary.enum_.operator.assign, tp ), //
					( cb, inst, args ) { //
						// 0th arg is Operator.assign!
						cb.build_primitiveOperation( BackendPrimitiveOperation.memCpy, inst, args[ 1 ] );
					} );
		}

		/// Returns binary operator symbol realized by primitive operation ( tp inst, operator, tp arg1 ) -> tp { tp tmp; tp <= inst operation arg1 }
		static Symbol newPrimitiveBinaryOp( Symbol_Type tp, Symbol_BootstrapConstant operator, BackendPrimitiveOperation operation ) {
			return new Symbol_PrimitiveMemberRuntimeFunction( ID!"#opBinary", tp, tp, //
					ExpandedFunctionParameter.bootstrap( operator, tp ), //
					( cb, inst, args ) { //
						// 0th arg is operator
						auto var = new DataEntity_TmpLocalVariable( tp, cb.isCtime );
						cb.build_localVariableDefinition( var );
						cb.build_primitiveOperation( operation, var, inst, args[ 1 ] );

						// Store var into result operand
						var.buildCode( cb );
					} );
		}

		/// Returns binary operator symbol realized by primitive operation ( tp inst, operator, tp arg1 ) -> tp { tp2 tmp; tp <= inst operation arg1 }
		static Symbol newPrimitiveBinaryOp( Symbol_Type tp, Symbol_Type returnType, Symbol_BootstrapConstant operator, BackendPrimitiveOperation operation ) {
			return new Symbol_PrimitiveMemberRuntimeFunction( ID!"#opBinary", tp, returnType, //
					ExpandedFunctionParameter.bootstrap( operator, tp ), //
					( cb, inst, args ) { //
						// 0th arg is operator
						auto var = new DataEntity_TmpLocalVariable( returnType, cb.isCtime );
						cb.build_localVariableDefinition( var );
						cb.build_primitiveOperation( operation, tp, var, inst, args[ 1 ] );

						// Store var into result operand
						var.buildCode( cb );
					} );
		}

		/// Returns binary operator symbols that represent bit comparison (==, !=)
		static Symbol[ ] newPrimitiveEqNeqOp( Symbol_Type tp ) {
			return [ new Symbol_PrimitiveMemberRuntimeFunction( ID!"#opBinary", tp, coreType.Bool, //
					ExpandedFunctionParameter.bootstrap( coreLibrary.enum_.operator.binEq, tp ), //
					( cb, inst, args ) { //
						// 0th arg is operator
						auto var = new DataEntity_TmpLocalVariable( coreType.Bool, cb.isCtime );
						cb.build_localVariableDefinition( var );
						cb.build_primitiveOperation( BackendPrimitiveOperation.memEq, tp, var, inst, args[ 1 ] );

						// Store var into result operand
						var.buildCode( cb );
					} ), //
				new Symbol_PrimitiveMemberRuntimeFunction( ID!"#opBinary", tp, coreType.Bool, //
						ExpandedFunctionParameter.bootstrap( coreLibrary.enum_.operator.binNeq, tp ), //
						( cb, inst, args ) { //
							// 0th arg is operator
							auto var = new DataEntity_TmpLocalVariable( coreType.Bool, cb.isCtime );
							cb.build_localVariableDefinition( var );
							cb.build_primitiveOperation( BackendPrimitiveOperation.memNeq, tp, var, inst, args[ 1 ] );

							// Store var into result operand
							var.buildCode( cb );
						} ) ];
		}

	protected:
		final static class Data : super.Data {

			public:
				this( Symbol_PrimitiveMemberRuntimeFunction sym, DataEntity parentInstance, MatchLevel matchLevel ) {
					super( sym, matchLevel );

					sym_ = sym;
					parentInstance_ = parentInstance;

					debug if ( parentInstance )
						assert( parentInstance.dataType is sym.parent_, "Parent instance is of type %s, but %s expected (%s)".format( parentInstance.dataType.identificationString, sym.parent_.identificationString, identificationString ) );
				}

			public:
				override DataEntity parent( ) {
					return parentInstance_ ? parentInstance_ : sym_.parent_.dataEntity;
				}

				override string identificationString_noPrefix( ) {
					return "%s.%s".format( sym_.parent_.identificationString, identification );
				}

				override CallableMatch startCallMatch( AST_Node ast, bool canThrowErrors, MatchLevel matchLevel ) {
					if ( parentInstance_ )
						return new Match( sym_, this, ast, canThrowErrors, matchLevel | this.matchLevel );
					else {
						benforce( !canThrowErrors, E.needThis, "Need this for %s".format( this.tryGetIdentificationString ) );
						return new InvalidCallableMatch( this, "need this" );
					}
				}

			private:
				DataEntity parentInstance_;
				Symbol_PrimitiveMemberRuntimeFunction sym_;

		}

		final static class Match : super.Match {

			public:
				this( Symbol_PrimitiveMemberRuntimeFunction sym, Data sourceEntity, AST_Node ast, bool canThrowErrors, MatchLevel matchLevel ) {
					super( sym, sourceEntity, sourceEntity.parentInstance_, ast, canThrowErrors, matchLevel );
					sym_ = sym;
				}

			protected:
				override DataEntity _toDataEntity( ) {
					return new MatchData( sym_, this );
				}

			private:
				Symbol_PrimitiveMemberRuntimeFunction sym_;

		}

		final static class MatchData : super.MatchData {

			public:
				this( Symbol_PrimitiveMemberRuntimeFunction sym, Match match ) {
					super( sym, match );

					sym_ = sym;
				}

			public:
				override void buildCode( CodeBuilder cb ) {
					const auto _gd = ErrorGuard( codeLocation );

					sym_.func_( cb, parentInstance_, arguments_ );
				}

			private:
				Symbol_PrimitiveMemberRuntimeFunction sym_;

		}

}
