module beast.code.sym.var.userstatic;

import beast.code.sym.toolkit;
import beast.code.sym.var.variable;
import beast.code.sym.var.static_;
import beast.code.data.toolkit;
import beast.code.data.scope_.root;

/// User (programmer) defined static variable
final class Symbol_UserStaticVariable : Symbol_StaticVariable {
	mixin TaskGuard!"typeDeduction";

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

	override AST_Node ast() {
		return ast_;
	}

private:
	DecorationList decorationList_;
	AST_VariableDeclaration ast_;
	Symbol_Type type_;

private:
	void execute_typeDeduction( ) {
		const auto _gd = ErrorGuard( ast_.type.codeLocation );

		// TODO: if type auto
		with ( memoryManager.session ) {
			RootDataScope scope_ = new RootDataScope( parentNamespace.symbol.data, "(type)" );
			type_ = ast_.type.build( ctimeCodeBuilder, coreLibrary.types.Type, scope_ ).ctValue_Type;
			scope_.buildCleanup( ctimeCodeBuilder );
			scope_.finish();

			assert( type_ );
		}

		import std.stdio;

		writefln( "%s TYPE: %s", identificationString, type_.identificationString );
	}

}
