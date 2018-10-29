module beast.code.entity.function_.expandedparameter;

import beast.code.entity.function_.toolkit;
import beast.util.identifiable;
import beast.code.ast.expr.vardecl;
import beast.code.entity.var.static_;

/// Expanded function parameter
final class ExpandedFunctionParameter : Identifiable {
	mixin TaskGuard!"outerHashObtaining";

public:
	static ExpandedFunctionParameter[] bootstrap(Args...)(Args args) {
		ExpandedFunctionParameter[] result;
		size_t runtimeIndex;

		foreach (i, arg; args) {
			ExpandedFunctionParameter param = new ExpandedFunctionParameter;
			param.index = i;
			param.identifier = Identifier("p%s".format(i));

			alias Arg = typeof(arg);
			// Type > > runtime argument
			static if (is(Arg : Symbol_Type)) {
				param.dataType = arg;
				param.runtimeIndex = runtimeIndex++;

			}
			// Data entity -> constval
			else static if (is(Arg : DataEntity)) {
				param.dataType = arg.dataType;
				auto _s = new RootDataScope(null);
				auto _sgd = _s.scopeGuard;

				param.constValue = arg.ctExec().keepForever.inStandaloneSession;

				assert(_s.itemCount <= 1);
			}
			// Static variable -> constval
			else static if (is(Arg : Symbol_StaticVariable)) {
				param.dataType = arg.dataType;
				param.constValue = arg.memoryPtr;
			}
			else
				static assert(0, "Invalid parameter %s of type %s".format(i, Arg.stringof));

			result ~= param;
		}

		return result;
	}

public:
	bool isConstValue() {
		return !constValue.isNull;
	}

public:
	/// Can be null for const-value parameters
	Identifier identifier;

	/// Data type of the parameter
	Symbol_Type dataType;

	/// If the parameter is const-value (something like template specialization), this points to the value
	MemoryPtr constValue;

	/// Index of the parameter
	size_t index;

	/// Runtime index of the parameter (considers only runtime parameters, not constvals etc)
	size_t runtimeIndex;

	AST_Expression ast;

public:
	Hash outerHash() {
		enforceDone_outerHashObtaining();
		return outerHashWIP_;
	}

	override string identificationString() {
		if (isConstValue)
			return "@ctime %s = %s".format(dataType.tryGetIdentificationString, dataType.valueIdentificationString(constValue));
		else if (identifier)
			return "%s %s".format(dataType.tryGetIdentificationString, identifier.str);
		else
			return dataType.tryGetIdentificationString;
	}

private:
	Hash outerHashWIP_;
	void execute_outerHashObtaining() {
		outerHashWIP_ = dataType.outerHash + Hash(index);

		if (isConstValue)
			outerHashWIP_ += Hash(constValue.read(dataType.instanceSize));
	}

}
