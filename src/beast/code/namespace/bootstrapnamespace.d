module beast.code.namespace.bootstrapamespace;

import beast.code.namespace.namespace;

final class BootstrapNamespace : Namespace {

public:
	this(Symbol[] items) {
		foreach (Symbol item; items)
			items_.require(item.identifier, null) ~= item;
	}

public:
	override Symbol[] resolveIdentifier(Identifier identifier) {
		return items_.get(identifier, null);
	}

private:
	Symbol[][Identifier] items_;

}
