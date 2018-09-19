module beast.code.data.module_.bootstrap;

import beast.code.data.toolkit;
import beast.code.data.module_.module_;
import beast.code.data.codenamespace.namespace;
import beast.code.lex.identifier : ExtendedIdentifier;
import beast.code.data.codenamespace.bootstrap;

/// Module that is defined in this compiler code
final class Symbol_BootstrapModule : Symbol_Module {

public:
	this(ExtendedIdentifier identifier) {
		identifier_ = identifier;
		namespace_ = new BootstrapNamespace(this);
	}

	void initialize(Symbol[] symbols) {
		namespace_.initialize(symbols);
	}

public:
	override Identifier identifier() {
		return identifier_[$ - 1];
	}

	override string identificationString() {
		return identifier_.str;
	}

protected:
	override Namespace namespace() {
		return namespace_;
	}

private:
	BootstrapNamespace namespace_;
	ExtendedIdentifier identifier_;

}
