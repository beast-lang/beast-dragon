module beast.code.semantic.overloadset;

import beast.code.semantic.toolkit;
import beast.code.semantic.decorator.decorator;
import beast.code.ast.expr.parentcomma;
import beast.code.semantic.callable.match;
import beast.code.semantic.scope_.local;
import beast.code.ast.expr.expression;
import std.range : isInputRange, ElementType;

struct Overloadset {

public:
	this(SemanticEntity[] data) {
		this.data = data;
	}

	this(Range)(Range data) if (isInputRange!Range) {
		this.data = data.array;
	}

	this(SemanticEntity entity) {
		data = [entity];
	}

public:
	SemanticEntity[] data;
	alias data this;

public:
	/// Returns list of decorators in the overloadset
	Symbol_Decorator[] filter_decoratorsOnly() {
		import std.array : appender;

		auto result = appender!(Symbol_Decorator[]);
		foreach (item; data) {
			if (auto deco = item.isDecorator)
				result ~= deco;
		}

		return result.data;
	}

public:
	/// Returns single entry from the overloadset
	/// If the overloadset is empty, throws noMatchingOverload error, if it contains multiple items, throws ambiguousResolution error
	SemanticEntity single() {
		benforce(data.length < 2, E.ambiguousResolution, "Expression is ambigous; can be one of:%s".format(data.map!(x => "\n\t%s".format(x.tryGetIdentificationString)).joiner));
		benforce(data.length > 0, E.noMatchingOverload, "Empty overloadset (more explaining message should have been shown, this would probably deserve a bug report)");
		return data[0];
	}

	/// Returns single entry from the overloadset that is of expected type or implicitly converible to to it
	/// Throws error if no matching overload is found (or the result is ambiguous)
	/// The expectedType can be null, in that case, the "single"" function is called
	SemanticEntity single_expectType(Symbol_Type expectedType) {
		if (!expectedType)
			return this.single();

		benforce(data.length > 0, E.noMatchingOverload, "Empty overloadset (more explaining message should have been shown, this would probably deserve a bug report)");

		SemanticEntity result;

		foreach (item; data) {
			item = item.tryCast(expectedType);

			if (!item)
				continue;

			// TODO: Maybe better ambiguity error msg?
			benforce(result is null, E.ambiguousResolution, "Expression is ambigous: can be '%s' or '%s' (or ...)".format(result, item));
			result = item;
		}

		benforce(result !is null, E.noMatchingOverload, //
				data.length == 1 //
				 ? "Cannot convert '%s' to '%s'".format(data[0].identificationString, expectedType.identificationString) //
				 : "None of overloads is convertible to '%s'".format(expectedType.identificationString) //
				);

		assert(result.dataType is expectedType);
		return result;
	}

public:
	/// Resolves call with given arguments (can either be AST_Expression or DataEntity or ranges of both)
	SemanticEntity resolveCall(Args...)(AST_Node ast, bool reportErrors, Args args) {
		auto _gd = ErrorGuard(ast);
		return CallMatchSet(this, ast, reportErrors).args(args).finish();
	}

public:
	string identificationString() {
		return "[ %s ]".format(data.map!(x => x.dataType.tryGetIdentificationString).joiner(", ").array);
	}

public:
	bool isEmpty() const {
		return data.length == 0;
	}

public:
	bool opCast(T : bool)() const {
		return data.length > 0;
	}

}
