module beast.code.data.var.userstatic;

import beast.code.data.toolkit;
import beast.code.data.var.static_;
import beast.code.decorationlist;
import beast.code.ast.decl.variable;
import beast.code.data.scope_.root;
import beast.backend.ctime.codebuilder;
import beast.code.data.util.subst;

/// User (programmer) defined static variable
final class Symbol_UserStaticVariable : Symbol_StaticVariable {
	mixin TaskGuard!"typeDeduction";
	mixin TaskGuard!"memoryAllocation";

	public:
		this( AST_VariableDeclaration ast, DecorationList decorationList, VariableDeclarationData data ) {
			super( data.env.staticMembersParent );
			assert( data.isStatic );

			ast_ = ast;
			decorationList_ = decorationList;
			isCtime_ = data.isCtime;

			taskManager.issueJob( { enforceDone_memoryAllocation( ); } );
		}

	public:
		override Identifier identifier( ) {
			return ast_.identifier;
		}

		override Symbol_Type dataType( ) {
			enforceDone_typeDeduction( );
			return dataTypeWIP_;
		}

		override AST_Node ast( ) {
			return ast_;
		}

		override MemoryPtr memoryPtr( ) {
			enforceDone_memoryAllocation( );
			return memoryPtrWIP_;
		}

		override bool isCtime( ) {
			return isCtime_;
		}

	private:
		DecorationList decorationList_;
		AST_VariableDeclaration ast_;
		Symbol_Type dataTypeWIP_;
		MemoryPtr memoryPtrWIP_;
		bool isCtime_;

	private:
		void execute_typeDeduction( ) {
			const auto _gd = ErrorGuard( ast_.dataType.codeLocation );

			// When the type is auto (deduced), the type deduction actually takes place in memoryAllocation
			if ( ast_.dataType.isAutoExpression )
				enforceDone_memoryAllocation( );
			else
				dataTypeWIP_ = ast_.dataType.standaloneCtExec( coreLibrary.type.Type, parent ).readType( );

			benforce( dataTypeWIP_.instanceSize > 0, E.zeroSizeVariable, "Type '%s' has zero instance size".format( dataTypeWIP_.identificationString ) );

			decorationList_.enforceAllResolved( );
		}

		void execute_memoryAllocation( ) {
			const auto _gd = ErrorGuard( ast_.dataType.codeLocation );

			with ( memoryManager.session ) {
				auto _s = scoped!RootDataScope( parent );
				auto _sgd = _s.scopeGuard;

				auto cb = scoped!CodeBuilder_Ctime( );

				MemoryBlock block;

				// We can't use this.dataEntity because that would cause a dependency loop (as we would require memoryPtr for this in it)
				if ( ast_.dataType.isAutoExpression ) {
					benforce( ast_.value !is null, E.missingInitValue, "Variable '%s.%s' definition needs implicit value for type deduction".format( parent.identificationString, identifier.str ) );

					DataEntity valueEntity = ast_.value.buildSemanticTree_single();
					dataTypeWIP_ = valueEntity.dataType;

					block = memoryManager.allocBlock( dataTypeWIP_.instanceSize, MemoryBlock.Flag.doNotGCAtSessionEnd );
					memoryPtrWIP_ = block.startPtr;

					DataEntity substEntity = new SubstitutiveDataEntity( memoryPtrWIP_, dataTypeWIP_ );
					ast_.buildConstructor( substEntity, valueEntity, cb );
				}
				else {
					auto dataType = dataType;

					block = memoryManager.allocBlock( dataType.instanceSize, MemoryBlock.Flag.doNotGCAtSessionEnd );
					memoryPtrWIP_ = block.startPtr;
					
					DataEntity substEntity = new SubstitutiveDataEntity( memoryPtrWIP_, dataType );
					ast_.buildConstructor( substEntity, cb );
				}

				block.identifier = identifier.str;

				// We have to mark the variable as runtime after calling its constructor (which is done at ctime)
				if ( !isCtime_ )
					block.flags |= MemoryBlock.Flag.runtime;

				_s.finish( );
			}
		}

}
