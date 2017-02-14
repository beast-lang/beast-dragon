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

public:
	override @property AST_Node ast( ) {
		return ast_;
	}

public:
	override Overloadset resolveIdentifier( Identifier id ) {
		if ( auto result = super.resolveIdentifier( id ) )
			return result;

		if ( auto result = namespace_.resolveIdentifier( id ) )
			return result;

		return Overloadset( );
	}

private:
	Symbol[ ] obtain_members( ) {
		return ast_.declarationScope.executeDeclarations( declarationEnvironment_module );
	}

private:
	UserNamespace namespace_;
	AST_Module ast_;

}
