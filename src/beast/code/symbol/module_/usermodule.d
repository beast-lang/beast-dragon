module beast.code.symbol.module_.usermodule;

import beast.code.symbol.toolkit;
import beast.code.module_;
import beast.code.ast.decl.module_;
import beast.code.symbol.module_.module_;

/// User (programmer) defined module
final class Symbol_UserModule : Symbol_Module {

public:
	this( Module module_, AST_Module ast ) {
		this.module_ = module_;
		ast_ = ast;

		namespace_ = new Namespace_Module( this );
		ast.relateWithSymbol( this );
	}

public:
	/// Corresponing module instance
	Module module_;

public:
	override @property Namespace namespace( ) {
		return namespace_;
	}

	override @property CodeLocation codeLocation( ) const {
		return CodeLocation( module_ );
	}

	override @property const( Identifier ) identifier( ) const {
		return module_.identifier[ $ - 1 ];
	}

	override @property string identificationString( ) const {
		return module_.identifier.str;
	}

private:
	Namespace_Module namespace_;
	AST_Module ast_;

}

final class Namespace_Module : Namespace {

public:
	this( Symbol_Module moduleSymbol ) {
		this.moduleSymbol = moduleSymbol;
	}

public:
	Symbol_Module moduleSymbol;

public:
	override @property Namespace parentNamespace( ) {
		return null;
	}

	override @property Symbol relatedSymbol( ) {
		return moduleSymbol;
	}

	@property string identificationString( ) const {
		return moduleSymbol.identificationString;
	}

protected:
	override Symbol[ ] obtain_members( ) {
		Symbol[ ] result;

		// TODO: THIS

		return result;
	}

}
