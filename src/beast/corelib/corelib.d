module beast.corelib.corelib;

import beast.corelib.toolkit;
import beast.corelib.type.types;
import beast.corelib.deco.decorators;
import beast.corelib.const_.constants;
import beast.code.semantic.module_.bootstrap;
import beast.code.lex.identifier;
import beast.corelib.const_.enums;
import beast.corelib.deco.functions;

/// Constructs core libraries (if they already are not constructed)
void constructCoreLibrary() {
	assert(!coreLibrary);

	coreLibrary = new CoreLibrary;
	coreLibrary.initialize();
}

/// Class containing core libraries symbols
class CoreLibrary {

public:
	/// Core types (primitives, Type, ...)
	CoreLibrary_Types type;

	/// Core decorators (static, ctime, ...)
	CoreLibrary_Decorators decorator;

	/// Core constants (true, false, ...)
	CoreLibrary_Constants constant;

	/// Core enums (Operator, ...)
	CoreLibrary_Enums enum_;

	/// Functions (print, ...)
	CoreLibrary_Functions function_;

public:
	/// Module where all core stuff is in
	/// This module is not "imported" anywhere; instead, lookup in it is hardwired in the Symbol_Module.tryRecursivelyResolveIdentifier
	Symbol_BootstrapModule module_;

public:
	void initialize() {
		module_ = new Symbol_BootstrapModule(ExtendedIdentifier.preobtained!"core");
		Symbol[] symbols;
		void delegate(Symbol) sink = (s) { symbols ~= s; };

		auto entity = module_.dataEntity;

		type.initialize(sink, entity);
		constant.initialize(sink, entity);
		decorator.initialize(sink, entity);
		enum_.initialize(sink, entity);
		function_.initialize(sink, entity);

		type.initialize2();
		enum_.initialize2();

		module_.initialize(symbols);
	}

}

__gshared CoreLibrary coreLibrary;

ref CoreLibrary_Types coreType() {
	return coreLibrary.type;
}

ref CoreLibrary_Constants coreConst() {
	return coreLibrary.constant;
}

ref CoreLibrary_Enums coreEnum() {
	return coreLibrary.enum_;
}

ref CoreLibrary_Functions coreFunc() {
	return coreLibrary.function_;
}
