module beast.code.symbol.module_.usermodule;

import beast.code.symbol.toolkit;
import beast.core.project.module_;
import beast.code.ast.decl.module_;
import beast.code.symbol.module_;

/// User (programmer) defined module
final class Symbol_UserModule : Symbol_Module {

public:
	this( Module module_, AST_Module ast ) {
		this.module_ = module_;
		ast_ = ast;

		namespace_ = new Namespace_UserModule( this );
		ast_.relateWithSymbol( this );
	}

public:
	/// Corresponing module instance
	Module module_;

public:
	override @property CodeLocation codeLocation( ) {
		return CodeLocation( module_ );
	}

	override @property Identifier identifier( ) {
		return module_.identifier[ $ - 1 ];
	}

	override @property string identificationString( ) {
		return module_.identifier.str;
	}

private:
	Namespace_UserModule namespace_;
	AST_Module ast_;

}

final class Namespace_UserModule : Namespace {

public:
	this( Symbol_Module module_ ) {
		this.module_ = module_;
	}

public:
	Symbol_Module module_;

public:
	override @property Symbol relatedSymbol( ) {
		return module_;
	}

protected:
	override Symbol[ ] obtain_members( ) {
		Symbol[ ] result;

		// TODO: THIS

		return result;
	}

}
