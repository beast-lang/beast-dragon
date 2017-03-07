module beast.code.data.var.userstatic;

import beast.code.data.toolkit;
import beast.code.data.var.static_;
import beast.code.decorationlist;
import beast.code.ast.decl.variable;

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

			taskManager.issueJob( { enforceDone_typeDeduction( ); } );
		}

	public:
		override Identifier identifier( ) {
			return ast_.identifier;
		}

		override Symbol_Type dataType( ) {
			enforceDone_typeDeduction( );
			return dataType_;
		}

		override AST_Node ast( ) {
			return ast_;
		}

		override MemoryPtr memoryPtr( ) {
			enforceDone_memoryAllocation( );
			return memoryPtr_;
		}

		override bool isCtime( ) {
			return isCtime_;
		}

	private:
		DecorationList decorationList_;
		AST_VariableDeclaration ast_;
		Symbol_Type dataType_;
		bool isCtime_;

	private:
		void execute_typeDeduction( ) {
			const auto _gd = ErrorGuard( ast_.dataType.codeLocation );

			// TODO: if type auto
			dataType_ = ast_.dataType.standaloneCtExec( coreLibrary.types.Type, parent ).readType( );

			benforce!( ErrorSeverity.warning )( dataType_.instanceSize > 0, E.zeroSizeVariable, "Type '%s' has zero instance size".format( dataType_.identificationString ) );
		}

		void execute_memoryAllocation( ) {
			const auto _gd = ErrorGuard( ast_.dataType.codeLocation );

			with ( memoryManager.session )
				memoryPtr_ = memoryManager.alloc( dataType_.instanceSize, isCtime_ ? MemoryBlock.Flag.noFlag : MemoryBlock.Flag.runtime, identifier.str );
		}

}
