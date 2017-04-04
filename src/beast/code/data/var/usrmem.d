module beast.code.data.var.usrmem;

import beast.code.data.toolkit;
import beast.code.data.var.static_;
import beast.code.decorationlist;
import beast.code.ast.decl.variable;
import beast.code.data.scope_.root;
import beast.backend.ctime.codebuilder;
import beast.code.data.util.subst;
import beast.code.data.var.mem;

/// User (programmer) defined member variable
final class Symbol_UserMemberVariable : Symbol_MemberVariable {
	mixin TaskGuard!"typeDeduction";

	public:
		this( AST_VariableDeclaration ast, DecorationList decorationList, VariableDeclarationData data ) {
			super( data.env.parentType, data.env.enforceDone_memberOffsetObtaining );
			assert( !data.isStatic );

			ast_ = ast;
			decorationList_ = decorationList;
			isCtime_ = data.isCtime;

			taskManager.delayedIssueJob( { enforceDone_typeDeduction( ); } );
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

	private:
		DecorationList decorationList_;
		AST_VariableDeclaration ast_;
		Symbol_Type dataTypeWIP_;
		bool isCtime_;

	private:
		void execute_typeDeduction( ) {
			const auto _gd = ErrorGuard( ast_.dataType.codeLocation );

			// When the type is auto (deduced), the type deduction actually takes place in memoryAllocation
			if ( ast_.dataType.isAutoExpression )
				berror( E.notImplemented, "Auto member variables not implemented" );
			else
				dataTypeWIP_ = ast_.dataType.standaloneCtExec( coreLibrary.type.Type, parent ).readType( );

			benforce( dataTypeWIP_.instanceSize > 0, E.zeroSizeVariable, "Type '%s' has zero instance size".format( dataTypeWIP_.identificationString ) );

			decorationList_.enforceAllResolved( );
		}

}
