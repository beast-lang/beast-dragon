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

		namespace_ = new UserNamespace( this, &obtain_members );
		ast_.relateWithSymbol( this );
	}

public:
	/// Corresponing module instance
	Module module_;

public:
	override @property AST_Node ast( ) {
		return ast_;
	}

	override @property Identifier identifier( ) {
		return module_.identifier[ $ - 1 ];
	}

	override @property string identificationString( ) {
		return module_.identifier.str;
	}

private:
	Symbol[] obtain_members() {
		Symbol[] result;

		// TODO: implement

		return result;
	}

private:
	UserNamespace namespace_;
	AST_Module ast_;

}