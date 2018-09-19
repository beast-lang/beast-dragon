module beast.code.data.function_.nonrt;

import beast.code.data.function_.toolkit;

/// Non-runtime function = function with @ctime arguments or auto params or so
abstract class Symbol_NonRuntimeFunction : Symbol_Function {

	static class Data : SymbolRelatedDataEntity {

	public:
		this(Symbol_NonRuntimeFunction sym, MatchLevel matchLevel) {
			super(sym, matchLevel);
		}

	public:
		override string identificationString() {
			return "auto %s".format(identificationString_noPrefix);
		}

	}

}
