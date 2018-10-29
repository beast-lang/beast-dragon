module beast.corelib.const_.constants;

import beast.corelib.toolkit;
import beast.code.entity.var.btspconst;
import beast.util.decorator;

struct CoreLibrary_Constants {

public:
	/// ( type, value )
	alias constant = Decorator!("corelib.constants.constant", string, ulong);

public:
	@constant("Bool", 0x01)
	Symbol_BootstrapConstant true_;

	@constant("Bool", 0x00)
	Symbol_BootstrapConstant false_;

public:
	void initialize(void delegate(Symbol) sink, DataEntity parent) {
		import std.string : chomp;

		auto types = coreType;

		foreach (memName; __traits(derivedMembers, typeof(this))) {
			foreach (attr; __traits(getAttributes, __traits(getMember, this, memName))) {
				static if (is(typeof(attr) == constant)) {
					sink( //
							__traits(getMember, this, memName) = new Symbol_BootstrapConstant( //
							parent, //
							memName.chomp("_").Identifier, //
							__traits(getMember, types, attr[0]), //
							attr[1] //
							) //
					);

					break;
				}
			}
		}
	}

}
