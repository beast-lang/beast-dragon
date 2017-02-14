module beast.code.sym.module_.user;

import beast.code.sym.toolkit;
import beast.core.project.module_;
import beast.code.ast.decl.module_;
import beast.code.sym.module_.module_;
import beast.code.ast.decl.env;

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
	override @property Identifier identifier( ) {
		return module_.identifier[ $ - 1 ];
	}

	override @property string identificationString( ) {
		return module_.identifier.str;
	}

	override @property Namespace namespace() {
		return namespace_;
	}

	override @property AST_Node ast( ) {
		return ast_;
	}

private:
	Symbol[ ] obtain_members( ) {
		return ast_.declarationScope.executeDeclarations( declarationEnvironment_module );
	}

private:
	UserNamespace namespace_;
	AST_Module ast_;

}
