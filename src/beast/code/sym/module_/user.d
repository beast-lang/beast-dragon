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

		namespace_ = new UserNamespace( this, &execute_membersObtaining );
		ast_.relateWithSymbol( this );
	}

public:
	/// Corresponing module instance
	Module module_;

public:
	override Identifier identifier( ) {
		return module_.identifier[ $ - 1 ];
	}

	override string identificationString( ) {
		return module_.identifier.str;
	}

	override Namespace namespace( ) {
		return namespace_;
	}

	override AST_Node ast( ) {
		return ast_;
	}

public:
	override string identification( ) {
		return module_.identifier.str;
	}

private:
	Symbol[ ] execute_membersObtaining( ) {
		DeclarationEnvironment env = DeclarationEnvironment.newModule;
		env.parentNamespace = namespace_;

		return ast_.declarationScope.executeDeclarations( env );
	}

private:
	UserNamespace namespace_;
	AST_Module ast_;

}
