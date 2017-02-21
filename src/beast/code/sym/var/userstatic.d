module beast.code.sym.var.userstatic;

import beast.code.sym.toolkit;
import beast.code.sym.var.variable;
import beast.code.sym.var.static_;
import beast.code.data.toolkit;
import beast.code.data.scope_.root;

/// User (programmer) defined static variable
final class Symbol_UserStaticVariable : Symbol_StaticVariable {
	mixin TaskGuard!"typeDeduction";
	mixin TaskGuard!"memoryAllocation";

public:
	this( AST_VariableDeclaration ast, DecorationList decorationList, DeclarationEnvironment env ) {
		super( env.parentNamespace );

		ast_ = ast;
		decorationList_ = decorationList;

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

private:
	DecorationList decorationList_;
	AST_VariableDeclaration ast_;
	Symbol_Type type_;
	MemoryPtr dataPtr_;

private:
	void execute_typeDeduction( ) {
		const auto _gd = ErrorGuard( ast_.type.codeLocation );

		// TODO: if type auto
		type_ = ast_.type.standaloneCtExec( coreLibrary.types.Type, parentNamespace.symbol.data ).readType( );

		benforce!( ErrorSeverity.warning )( type_.instanceSize > 0, E.zeroSizeVariable, "Type '%s' has zero instance size".format( type_.identificationString ) );
	}

	void execute_memoryAllocation( ) {
		const auto _gd = ErrorGuard( ast_.type.codeLocation );

		with( memoryManager.session ) {
			MemoryBlock b = memoryManager.allocBlock( dataType.instanceSize );
			b.flags |= MemoryBlock.Flags.runtime;
			dataPtr_ = b.startPtr;
		}
	}

}
