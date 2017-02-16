module beast.code.sym.module_.bootstrap;

import beast.code.sym.toolkit;
import beast.core.project.module_;
import beast.code.ast.decl.module_;
import beast.code.sym.module_.module_;
import beast.code.namespace.bootstrap;

/// Module that is defined in this compiler code
final class Symbol_BootstrapModule : Symbol_Module {

public:
	this( ExtendedIdentifier identifier ) {
		identifier_ = identifier;
		namespace_ = new BootstrapNamespace( this );
	}

	void initialize( Symbol[ ] symbols ) {
		namespace_.initialize( symbols );
	}

public:
	override Identifier identifier( ) {
		return identifier_[ $ - 1 ];
	}

	override string identificationString( ) {
		return identifier_.str;
	}

	override Namespace namespace() {
		return namespace_;
	}

private:
	BootstrapNamespace namespace_;
	ExtendedIdentifier identifier_;

}
