module beast.code.entity.dataentity;

import beast.code.entity.toolkit;
import beast.util.identifiable;
import beast.code.entity.decorator.decorator;
import beast.core.project.codelocation;
import beast.code.entity.callable.match;
import beast.code.entity.type.type;
import beast.code.entity.util.reinterpret;
import beast.code.entity.util.deref;
import beast.code.entity.util.subst;
import beast.core.ctxctimeguard;

/// DataEntity stores information about a value: what is its type and how to obtain it (how to build code that obtains it)
/// It is practically an expression semantic tree node
abstract class DataEntity : Identifiable {

public:
	this(MatchLevel matchLevel) {
		matchLevel_ = matchLevel;
	}

public:
	/// Type of the data; can be null (mostly when reflection is not implemented)
	abstract Symbol_Type dataType();

	/// Parent is used for toString formatting (usually it should be a symbol)
	abstract Identifiable parent();

	/// Specifies priority of this entity for overloading
	final MatchLevel matchLevel() {
		return matchLevel_;
	}

	/// If the data is known at compile time
	/// This can be false even if the entity is inferable at compile time (for example function calls)
	/// This is mostly used in operator overloading (ctime vs nonctime overloads)
	abstract bool isCtime();

	Symbol_Decorator isDecorator() {
		return null;
	}

public:
	/// Identifier of the data that vaguely corresponds with the symbol table (can be null)
	Identifier identifier() {
		return null;
	}

	/// Identification of the entity for error printing purposes
	override string str(ToStringFlags flags = 0) {
		string result;

		if (!(str & ToString.hideType))
			result ~= "%s ".format(dataType.str);

		if (identifier && parent)
			result ~= "%s.%s".format(parent.str(ToString.parentMask), identifier);
		else if (identifier)
			result ~= identifier.str;
		else
			result ~= "#tmp#";

		return result;
	}

	/// Executes the dataEntity at ctime and returns string describing its value
	pragma(inline) final string valueStr() {
		with (memoryManager.session(SessionPolicy.doNotWatchCtChanges)) {
			auto ctexec = ctExec();
			auto result = dataType.valueStr(ctexec.value);
			ctexec.destroy();

			return result;
		}
	}

	/// AST node related with the entity, can be null
	abstract AST_Node ast();

	/// Location in the code related to the data entity
	final CodeLocation codeLocation() {
		return ast ? ast.codeLocation : cast(CodeLocation) null;
	}

public:
	/// Resolves identifier (drill-down)
	/// The scope can be used for creating temporary variables
	/// Can return empty overloadset
	final bool resolveIdentifier(ref Overloadset overloadset, Identifier id, ResolutionFlags flags = ResolutionFlag.defaultFlags, MatchLevel matchLevel = MatchLevel.fullMatch) {
		if (resolveIdentifier_dataEntityCommon(overloadset, id, flags, matchLevel))
			return true;

		if (dataType.resolveIdentifier(overloadset, id, flags, this, matchLevel))
			return true;

		return false;
	}

protected:
	final bool resolveIdentifier_dataEntityCommon(ref Overloadset overloadset, Identifier id, ResolutionFlags flags = ResolutionFlag.defaultFlags, MatchLevel matchLevel = MatchLevel.fullMatch) {
		if (id == ID!"#type") {
			overloadset ~= dataType.dataEntity(null, matchLevel);
			return true;
		}

		return false;
	}

public:
	/// Returns if the current entity is callable
	bool isCallable() {
		return false;
	}

	/// Creates a class instance that is in charge of matching the currect callable entity with an argument list
	CallableMatch startCallMatch(AST_Node ast, bool canThrowErrors, MatchLevel matchRestriction) {
		assert(0, identificationString ~ " is not callable");
	}

	/// Resolves call with given arguments (can either be AST_Expression or DataEntity or ranges of both)
	final DataEntity resolveCall(Args...)(AST_Node ast, bool reportErrors, Args args) {
		auto _gd = ErrorGuard(ast);

		CallableMatch match = startCallMatch(ast, reportErrors, matchLevel_).args(args).finish();
		benforce(match.matchLevel != MatchLevel.noMatch, E.noMatchingOverload, "%s does not match given arguments: %s".format(this.str, match.errorStr));
		return match.toDataEntity();
	}

public:
	/// Enforces that the resulting entity is of dataType targetType (either returns itself or creates a cast call)
	final DataEntity enforceCast(Symbol_Type targetType) {
		if (dataType == targetType)
			return this;

		DataEntity result = tryCast(targetType);
		benforce(result !is null, E.notImplemented, "Casting is not implemented yet");

		return result;
	}

	/// Tries to cast to the targetType (or returns itself if already is of targe type). Returns null on failure
	final DataEntity tryCast(Symbol_Type targetType) {
		if (dataType is targetType)
			return this;

		if (auto castCall = resolveIdentifier(ID!"#implicitCast").resolveCall(ast, false, targetType.dataEntity)) {
			benforce(castCall.dataType is targetType, E.invalidCastReturnType, "%s has return type %s (#cast always have to return type given by first parameter)".format(castCall.identificationString, castCall.dataType.identificationString));
			return castCall;
		}

		/// TODO: alias this check
		return null;
	}

	/// Returns data entity representing this data entity reintrerpreted as targetType
	pragma(inline) final DataEntity reinterpret(Symbol_Type targetType) {
		return new DataEntity_ReinterpretCast(this, targetType);
	}

	/// Returns data entity representing data entity referenced by the current one (it is assumed that current data entity is of reference type)
	pragma(inline) final DataEntity dereference(Symbol_Type targetType) {
		return new DataEntity_DereferenceProxy(this, targetType);
	}

public:
	/// Builds code that matches the semantic tree (scope is used for variable allocations)
	void buildCode(CodeBuilder cb) {
		assert(0, "buildCode not implemented for " ~ identificationString);
	}

public:
	/// Executes the expression at compile time, returns result
	/// parentCodeBuilder needs to know what @ctime variables were created so it can mirror them
	pragma(inline) final CTExecResult ctExec() {
		auto __cgd = ContextCtimeGuard(true);
		scope cb = new CodeBuilder_Ctime;
		buildCode(cb);
		return cb.result;
	}

	/// Expects the data to point at Type instance
	final Symbol_Type ctExec_asType() {
		assert(dataType is coreType.Type);

		auto ctexec = ctExec();
		Symbol_Type type = ctexec.value.readType();
		ctexec.destroy();

		benforce(type !is null, E.invalidPointer, "'%s' does not point to a valid type".format(identificationString));
		return type;
	}

	final DataEntity ctExec_asDataEntity() {
		return new SubstitutiveDataEntity(ctExec.keepUntilSessionEnd, dataType);
	}

private:
	MatchLevel matchLevel_;

}
