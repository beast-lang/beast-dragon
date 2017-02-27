module beast.code.data.entitycontainer.namespace.bootstrap;

import beast.code.toolkit;
import beast.code.data.entitycontainer.namespace.namespace;

/// Namespace whose symbols are added manually in the compiler code
final class BootstrapNamespace : Namespace {

public:
	this( Symbol symbol, InstanceTransformer instanceTransformer = defaultInstanceTransformer ) {
		super( symbol, instanceTransformer );
	}

}
