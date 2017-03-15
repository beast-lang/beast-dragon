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

			// TODO: if type auto
			dataTypeWIP_ = ast_.dataType.standaloneCtExec( coreLibrary.type.Type, parent ).readType( );

			benforce( dataTypeWIP_.instanceSize > 0, E.zeroSizeVariable, "Type '%s' has zero instance size".format( dataTypeWIP_.identificationString ) );

			decorationList_.enforceAllResolved( );
		}

		void execute_memoryAllocation( ) {
			const auto _gd = ErrorGuard( ast_.dataType.codeLocation );

			with ( memoryManager.session ) {
				auto scope_ = scoped!RootDataScope( parent );
				auto cb = scoped!CodeBuilder_Ctime( );

				auto block = memoryManager.allocBlock( dataType.instanceSize, MemoryBlock.Flag.doNotGCAtSessionEnd );
				block.identifier = identifier.str;
				memoryPtrWIP_ = block.startPtr;

				// We can't use this.dataEntity because that would cause a dependency loop (as we would require memoryPtr for this in it)
				DataEntity substEntity = new SubstitutiveDataEntity( memoryPtrWIP_, dataType );
				ast_.buildConstructor( substEntity, scope_, cb );

				// We have to mark the variable as runtime after calling its constructor (which is done at ctime)
				if ( !isCtime_ )
					block.flags |= MemoryBlock.Flag.runtime;

				scope_.finish( );
			}
		}

}
