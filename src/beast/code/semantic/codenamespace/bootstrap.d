module beast.code.semantic.codenamespace.bootstrap;

import beast.code.semantic.toolkit;
import beast.code.semantic.codenamespace.namespace;
import beast.util.identifiable;

/// Namespace whose symbols are added manually in the compiler code
/// Call initialize with symbol list as an argument
final class BootstrapNamespace : Namespace {

public:
	this(Identifiable parent) {
		super(parent);
	}

public:
	final void initialize(Symbol[] symbolList) {
		initialize_(symbolList);
	}

}
