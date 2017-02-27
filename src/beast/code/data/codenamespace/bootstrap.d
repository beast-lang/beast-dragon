module beast.code.data.codenamespace.bootstrap;

import beast.code.toolkit;
import beast.code.data.codenamespace.namespace;

/// Namespace whose symbols are added manually in the compiler code
/// Call initialize with symbol list as an argument
final class BootstrapNamespace : Namespace {

public:
	final void initialize( Symbol[ ] symbolList ) {
		initialize_( symbolList );
	}

}
