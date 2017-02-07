module beast.code.symbol.module_.bootstrapmodule;

import beast.code.symbol.toolkit;
import beast.core.project.module_;
import beast.code.ast.decl.module_;
import beast.code.symbol.module_;
import beast.code.namespace.bootstrapnamespace;

/// Module that is defined in this compiler code
final class Symbol_BootstrapModule : Symbol_Module {

public:
	this( ExtendedIdentifier identifier, Symbol[ ] symbols ) {
		identifier_ = identifier;

		namespace_ = new BootstrapNamespace( this, symbols );
	}

public:
	override @property Identifier identifier( ) {
		return identifier_[ $ - 1 ];
	}

	override @property string identificationString( ) {
		return identifier_.str;
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
	BootstrapNamespace namespace_;
	ExtendedIdentifier identifier_;

}
