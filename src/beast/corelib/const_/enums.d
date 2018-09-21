module beast.corelib.const_.enums;

import beast.corelib.toolkit;
import beast.code.semantic.var.btspconst;
import beast.util.decorator;
import beast.code.semantic.type.btspenum;
import beast.code.semantic.function_.primstcrt;
import beast.code.memory.ptr;
import beast.code.semantic.function_.expandedparameter;
import beast.code.semantic.function_.primstcnrt;
import beast.code.ast.node;
import beast.code.semantic.util.reinterpret;

struct CoreLibrary_Enums {

private:
	alias C = Symbol_BootstrapConstant;
	alias E = Symbol_BootstrapEnum;

public:
	/// ( baseClass )
	alias enum_ = Decorator!("corelib.enum.enum_", string);
	alias standardEnumItems = Decorator!("corelib.enum.standardEnumItems", string);

public:
	@enum_("Int32")
	E Operator;

	struct OperatorItems {
		C binOr, binAnd;
		C binPlus, binMinus;
		C binMult, binDiv;

		C binEq, binNeq;
		C binLt, binLte;
		C binGte, binGt;

		C funcCall;

		C preNot;
		C suffRef, suffNot;

		C assign, refAssign;
	}

	@standardEnumItems("Operator")
	OperatorItems operator;

public:
	@enum_("Int32")
	E XXCtor;

	struct XXCtorItems {
		C refAssign; /// Ref assign constructor: #ctor( #Ctor.refAssign, val ) -> Var x := y
	}

	@standardEnumItems("XXCtor")
	XXCtorItems xxctor;

public:
	@enum_("Pointer")
	E Null;
	C null_;

public:
	void initialize(void delegate(Symbol) sink, DataEntity parent) {
		import std.string : chomp;
		import std.regex : ctRegex, replaceAll;

		auto types = coreType;

		foreach (memName; __traits(derivedMembers, typeof(this))) {
			foreach (attr; __traits(getAttributes, __traits(getMember, this, memName))) {
				static if (is(typeof(attr) == enum_)) {
					auto enum_ = new Symbol_BootstrapEnum( //
							parent, //
							memName.chomp("_").replaceAll(ctRegex!"XX", "#").Identifier, //
							__traits(getMember, types, attr[0]), //
							);
					__traits(getMember, this, memName) = enum_;

					sink(enum_);

					break;
				}
				else static if (is(typeof(attr) == standardEnumItems)) {
					InitRecord rec;
					rec.baseClass = __traits(getMember, this, attr[0]);
					ulong i = 0;

					foreach (subMemName; __traits(derivedMembers, typeof(__traits(getMember, typeof(this), memName)))) {
						rec.items ~= ( //
								__traits(getMember, __traits(getMember, this, memName), subMemName) = new Symbol_BootstrapConstant( //
								parent, //
								subMemName.chomp("_").Identifier, //
								rec.baseClass, //
								i //
								) //
						);

						i++;
					}

					initList_ ~= rec;
				}
			}
		}

		sink(null_ = new C(parent, ID!"null", Null, 0));
	}

	void initialize2() {
		foreach (rec; initList_)
			rec.baseClass.initialize(rec.items);

		{
			auto de = Null.dataEntity;
			auto nullDe = null_.dataEntity;

			Null.initialize([ //
					// Implicit cast to pointer
					new Symbol_PrimitiveStaticRuntimeFunction(ID!"#implicitCast", de, coreType.Pointer, //
					ExpandedFunctionParameter.bootstrap(coreType.Pointer.dataEntity), //
					(cb, args) {
						nullDe.buildCode(cb); //
					}), //

					// Implicit cast to any reference type
					new Symbol_PrimitiveStaticNonRuntimeFunction(ID!"#implicitCast", de, //
						Symbol_PrimitiveStaticNonRuntimeFunction.paramsBuilder().ctArg(coreType.Type).finishIf( //
						(MemoryPtr type) { auto tp = type.readType; return tp.isReferenceType ? null : "%s is not a reference type".format(tp.identificationString); }, // Condition function
						(AST_Node ast, MemoryPtr type) => new DataEntity_ReinterpretCast(nullDe, type.readType))) //

						]);
		}

		initList_ = null;
	}

private:
	struct InitRecord {
		Symbol_BootstrapEnum baseClass;
		Symbol[] items;
	}

	InitRecord[] initList_;

}
