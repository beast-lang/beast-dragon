module beast.code.data.var.userstatic;

import beast.code.data.var.variable;
import beast.code.data.var.static_;
import beast.code.data.toolkit;

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
		return type_;
	}

	override AST_Node ast( ) {
		return ast_;
	}

	override MemoryPtr dataPtr( ) {
		enforceDone_memoryAllocation( );
		return dataPtr_;
	}

	override bool isCtime( ) {
		return isCtime_;
	}

private:
	DecorationList decorationList_;
	AST_VariableDeclaration ast_;
	Symbol_Type type_;
	MemoryPtr dataPtr_;
	bool isCtime_;

private:
	void execute_typeDeduction( ) {
		const auto _gd = ErrorGuard( ast_.type.codeLocation );

		// TODO: if type auto
		type_ = ast_.type.standaloneCtExec( coreLibrary.types.Type, parent ).readType( );

		benforce!( ErrorSeverity.warning )( type_.instanceSize > 0, E.zeroSizeVariable, "Type '%s' has zero instance size".format( type_.identificationString ) );
	}

	void execute_memoryAllocation( ) {
		const auto _gd = ErrorGuard( ast_.type.codeLocation );

		with ( memoryManager.session ) {
			MemoryBlock b = memoryManager.allocBlock( dataType.instanceSize );

			if ( !isCtime_ )
				b.flags |= MemoryBlock.Flags.runtime;

			dataPtr_ = b.startPtr;
		}
	}

}
