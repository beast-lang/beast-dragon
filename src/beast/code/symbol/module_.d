module beast.code.symbol.module_;

import beast.code.symbol.toolkit;
import beast.code.module_;
import beast.code.ast.module_;

/// Module as a symbol
final class Symbol_Module : Symbol {

public:
	this( Module module_, AST_Module ast ) {
		this.module_ = module_;
		this.ast = ast;

		namespace = new Namespace_Module( this );
	}

public:
	/// Corresponing module instance
	Module module_;
	AST_Module ast;
	Namespace_Module namespace;

public:
	override @property CodeLocation codeLocation( ) const {
		return CodeLocation( module_ );
	}

	override @property const( Identifier ) identifier( ) const {
		return module_.identifier[ $ - 1 ];
	}

	override @property string identificationString( ) const {
		return module_.identifier.str;
	}

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
		Symbol[] result;

		// TODO: THIS

		return result;
	}

}
