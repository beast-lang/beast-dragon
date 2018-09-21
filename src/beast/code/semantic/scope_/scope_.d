module beast.code.semantic.scope_.scope_;

import beast.code.semantic.toolkit;
import beast.code.semantic.var.local;
import beast.code.semantic.idcontainer;
import beast.util.uidgen;

/// DatScope is basically a namespace for data entities (the "Namespace" class stores symbols) - it is a namespace with a context
/// DataScope is not responsible for calling destructors or constructors - destructors are handled by a codebuilder
/// Scope is expected to be accessed from one context only
abstract class DataScope : IDContainer {

protected:
	this(DataEntity parentEntity) {
		parentEntity_ = parentEntity;
		debug jobId_ = context.jobId;
	}

	~this() {
		//debug assert( isFinished_, "Scope destroyed but not finished" );
	}

public:
	/// Nearest DataEntity parent of the scope
	final DataEntity parentEntity() {
		return parentEntity_;
	}

	final override string identificationString() {
		return parentEntity.identificationString;
	}

	final size_t itemCount() {
		return localVariables_.length;
	}

public:
	final void addEntity(DataEntity entity_) {
		debug assert(allowMultiThreadAccess || context.jobId == jobId_, "DataScope is accessed from a different thread than it was created in");
		debug assert(!isFinished_, "Scope is finished (%s)".format(finishedAt_));

		auto id = entity_.identifier;
		assert(id, "You cannot add entities without an identifier to a scope");

		// Add to the overloadset
		if (auto it = id in groupedNamedVariables_)
			it.data ~= entity_;
		else
			groupedNamedVariables_[id] = Overloadset([entity_]);
	}

	final void addEntity(Symbol sym) {
		addEntity(sym.dataEntity);
	}

	/// Adds variable to the scope
	final void addLocalVariable(DataEntity_LocalVariable var) {
		localVariables_ ~= var;
		addEntity(var);
	}

	/// Marks the scope as not being editable anymore
	debug {
		void finish(string file = __FILE__, ulong line = __LINE__) {
			assert(!isFinished_, "Duplicate finish() of scope (finished at %s)".format(finishedAt_));
			isFinished_ = true;
			finishedAt_ = "%s:%s".format(file, line);
		}
	}
	else {
		void finish() {

		}
	}

public:
	Overloadset tryResolveIdentifier(Identifier id, MatchLevel matchLevel = MatchLevel.fullMatch) {
		debug assert(allowMultiThreadAccess || context.jobId == jobId_, "DataScope is accessed from a different thread than it was created in");

		if (auto result = id in groupedNamedVariables_)
			return *result;

		return Overloadset();
	}

public:
	debug final UIDGenerator.I jobId() {
		return jobId_;
	}

public:
	debug bool allowMultiThreadAccess;

private:
	DataEntity parentEntity_;
	/// All local variables, both named and temporary ones
	DataEntity_LocalVariable[] localVariables_;
	Overloadset[Identifier] groupedNamedVariables_;

	debug UIDGenerator.I jobId_;
	debug bool isFinished_;
	debug string finishedAt_;

package:
	/// Currently open subscope (used for checking there's maximally one at a time)
	debug DataScope openSubscope_;

}

/// Returns current scope for the current context
DataScope currentScope() {
	assert(context.currentScope);
	return context.currentScope;
}

// TODO: remove file, line args or make them debug
auto scopeGuard(DataScope scope_, bool finish = true, string file = __FILE__, ulong line = __LINE__) {
	struct Result {
		~this() {
			assert(context.currentScope is scope_);

			if (finish)
				scope_.finish(file, line);

			context.currentScope = context.scopeStack[$ - 1];
			context.scopeStack.length--;
		}

		DataScope scope_;
		bool finish;
	}

	context.scopeStack ~= context.currentScope;
	context.currentScope = scope_;

	return Result(scope_, finish);
}

/// Executes given function in a given data scope
pragma(inline) auto inDataScope(T)(lazy T dg, DataScope scope_, bool finish = true, string file = __FILE__, ulong line = __LINE__) {
	auto _gd = scope_.scopeGuard(finish, file, line);
	return dg();
}

/// Executes given function in a new local data scope
pragma(inline) auto inLocalDataScope(T)(lazy T dg, string file = __FILE__, ulong line = __LINE__) {
	import beast.code.semantic.scope_.local : LocalDataScope;

	auto _gd = new LocalDataScope().scopeGuard(true, file, line);
	return dg();
}

/// Executes given function in a new root data scope
pragma(inline) auto inRootDataScope(T)(lazy T dg, DataEntity parent, bool finish = true, string file = __FILE__, ulong line = __LINE__) {
	import beast.code.semantic.scope_.root : RootDataScope;

	auto _gd = new RootDataScope(parent).scopeGuard(finish, file, line);
	return dg();
}

/// Executes given function in a new blurry data scope
pragma(inline) auto inBlurryDataScope(T)(lazy T dg, DataScope parent, string file = __FILE__, ulong line = __LINE__) {
	import beast.code.semantic.scope_.blurry : BlurryDataScope;

	auto _gd = new BlurryDataScope(parent).scopeGuard(true, file, line);
	return dg();
}
