module beast.backend.common.codebuilder;

import beast.backend.toolkit;
import beast.util.identifiable;
import beast.backend.ctime.codebuilder : CodeBuilder_Ctime;
import beast.util.uidgen;
import std.algorithm.searching : all, canFind;

/// Root class for building code with any backend
abstract class CodeBuilder : Identifiable {

public:
	/// When called, StmtFunction should build given part of the statement using provided codebuilder
	alias StmtFunction = void delegate(CodeBuilder cb);

	/// When called, StmtFunction should build expression using provided codebuilder		
	alias ExprFunction = void delegate(CodeBuilder cb);

public:
	this() {
		scopeStack_ ~= Scope(0);
		debug scopeStack_[$ - 1].session = context.session;
	}

public:
	bool isCtime() {
		return false;
	}

public: // Declaration related build commands
	void build_localVariableDefinition(DataEntity_LocalVariable var) {
		assert(0, "%s not implemented for %s".format(__FUNCTION__, identificationString));
	}

	void build_functionDefinition(Symbol_RuntimeFunction func, StmtFunction body_) {
		assert(0, "%s not implemented for %s".format(__FUNCTION__, identificationString));
	}

	void build_typeDefinition(Symbol_Type type) {
		assert(0, "%s not implemented for %s".format(__FUNCTION__, identificationString));
	}

public: // Expression related build commands
	/// Builds access to a memory (passed by a pointer)
	/// The memory doesn't have to be static! You have to check associated memory block flags (it can be local ctime variable or so)
	void build_memoryAccess(MemoryPtr pointer) {
		assert(0, "%s not implemented for %s".format(__FUNCTION__, identificationString));
	}

	/// Builds access to a memory described by expr but offsetted with offset
	void build_offset(ExprFunction expr, size_t offset) {
		assert(0, "%s not implemented for %s".format(__FUNCTION__, identificationString));
	}

	void build_functionCall(Symbol_RuntimeFunction function_, DataEntity parentInstance, DataEntity[] arguments) {
		assert(0, "%s not implemented for %s".format(__FUNCTION__, identificationString));
	}

	void build_primitiveOperation(BackendPrimitiveOperation op, Symbol_Type argT = null, ExprFunction arg1 = null, ExprFunction arg2 = null, ExprFunction arg3 = null) {
		assert(0, "%s not implemented for %s".format(__FUNCTION__, identificationString));
	}

	/// Builds access to a memory referenced by given pointer arg
	void build_dereference(ExprFunction arg) {
		assert(0, "%s not implemented for %s".format(__FUNCTION__, identificationString));
	}

	/// Builds access to context ptr
	void build_contextPtrAccess() {
		assert(0, "%s not implemented for %s".format(__FUNCTION__, identificationString));
	}

	/// Builds access to a function parameter
	void build_parameterAccess(ExpandedFunctionParameter param) {
		assert(0, "%s not implemented for %s".format(__FUNCTION__, identificationString));
	}

	/// Builds access to a function result
	void build_functionResultAccess(Symbol_RuntimeFunction func) {
		assert(0, "%s not implemented for %s".format(__FUNCTION__, identificationString));
	}

	/// Utility function calling original build_primitiveOperation (argT => arg1.dataType)
	pragma(inline) final void build_primitiveOperation(BackendPrimitiveOperation op, DataEntity arg1) {
		build_primitiveOperation(op, arg1.dataType, &arg1.buildCode);
	}

	/// Utility function calling original build_primitiveOperation (argT => arg1.dataType)
	pragma(inline) final void build_primitiveOperation(BackendPrimitiveOperation op, DataEntity arg1, DataEntity arg2) {
		build_primitiveOperation(op, arg1.dataType, &arg1.buildCode, &arg2.buildCode);
	}

	/// Utility function calling original build_primitiveOperation (argT => arg1.dataType)
	pragma(inline) final void build_primitiveOperation(BackendPrimitiveOperation op, DataEntity arg1, DataEntity arg2, DataEntity arg3) {
		build_primitiveOperation(op, arg1.dataType, &arg1.buildCode, &arg2.buildCode, &arg3.buildCode);
	}

	/// Utility function calling original build_primitiveOperation
	pragma(inline) final void build_primitiveOperation(BackendPrimitiveOperation op, Symbol_Type argT, DataEntity arg1, DataEntity arg2, DataEntity arg3) {
		build_primitiveOperation(op, argT, &arg1.buildCode, &arg2.buildCode, &arg3.buildCode);
	}

public: // Statement related build commands
	void build_scope(StmtFunction body_) {
		assert(0, "%s not implemented for %s".format(__FUNCTION__, identificationString));
	}

	/// Builds the "if" construction
	/// Condition has to be of type bool
	/// elseBranch can be null
	void build_if(ExprFunction condition, StmtFunction thenBranch, StmtFunction elseBranch) {
		assert(0, "%s not implemented for %s".format(__FUNCTION__, identificationString));
	}

	/// Utility function for if
	final void build_if(DataEntity condition, StmtFunction thenBranch, StmtFunction elseBranch) {
		build_if(&condition.buildCode, thenBranch, elseBranch);
	}

	/// Builds the "loop" construction - infinite loop (has to be stopped using break)
	void build_loop(StmtFunction body_) {
		assert(0, "%s not implemented for %s".format(__FUNCTION__, identificationString));
	}

	/// Builds the "break" construction - exists the topmost breakable scope (breakable without a label)
	final void build_break() {
		foreach_reverse (i, ref s; scopeStack_) {
			if (s.flags & ScopeFlags.breakableWithoutLabel) {
				benforce(i != 0, E.nothingToBreakOrContinue, "There's nothing to break");
				build_break(i);
				return;
			}
		}

		berror(E.nothingToBreakOrContinue, "There is nothing you can break from implicitly - decorate the desired scope with @label( \"xx\" ) and then use \"break xx;\"");
	}

	/// Builds the "break" construction - exits all scopes up to given index (inclusive) (index is given by scopeStack_)
	void build_break(size_t scopeIndex) {
		assert(0, "%s not implemented for %s".format(__FUNCTION__, identificationString));
	}

	void build_return(DataEntity returnValue) {
		assert(0, "%s not implemented for %s".format(__FUNCTION__, identificationString));
	}

public:
	/// Builds a comment that is eventually incorporated into the code
	void build_comment(string comment) {

	}

public:
	final void build_copyCtor(DataEntity var, DataEntity initValue) {
		DataEntity_LocalVariable.getCopyCtor(var, initValue).buildCode(this);
	}

	final void build_dtor(DataEntity_LocalVariable var) {
		// Do not call destructors for ctime variables (yet)
		if (var.isCtime && !this.isCtime)
			return;

		// We don't call var.tryResolveIdentifier because of Type variables
		// calling var.tryResolveIdentifier would result in calling #ctor of the represented type
		var.dataType.expectResolveIdentifier_direct(ID!"#dtor", var).resolveCall(null, isCtime, true).buildCode(this);
	}

protected:
	/// Mirrors @ctime changes into the runtime code
	final void mirrorCtimeChanges() {
		if (this.isCtime || !context.sessionData.changedMemoryBlocks)
			return;

		auto changedMemoryBlocks = *context.sessionData.changedMemoryBlocks;
		auto newMemoryBlocks = *context.sessionData.newMemoryBlocks;

		foreach (block; newMemoryBlocks) {
			// We ignore memory blocks that are runtime
			// Also we ignore blocks with "doNotMirrorChanges" flag (those are for example memory blocks that store data for mirroring)
			if (block.isRuntime || block.flag(MemoryBlock.Flag.doNotMirrorChanges))
				continue;

			assert(block.flag(MemoryBlock.SharedFlag.allocated) && block.flag(MemoryBlock.SharedFlag.changed));

			// If the block has been both allocated and deallocated between two mirorrings, ignore it completely
			if (block.flag(MemoryBlock.SharedFlag.freed))
				continue;

			mirrorBlockAllocation(block);
		}

		foreach (block; changedMemoryBlocks) {
			// We ignore memory blocks that are runtime
			// Also we ignore blocks with "doNotMirrorChanges" flag (those are for example memory blocks that store data for mirroring)
			if (block.isRuntime || block.flag(MemoryBlock.Flag.doNotMirrorChanges))
				continue;

			// If the block has been both allocated and deallocated between two mirorrings, ignore it completely
			if (block.flag(MemoryBlock.SharedFlag.allocated | MemoryBlock.SharedFlag.freed))
				continue;

			assert(block.flag(MemoryBlock.SharedFlag.changed));

			if (block.flag(MemoryBlock.SharedFlag.freed))
				mirrorBlockDeallocation(block);
			else
				mirrorBlockDataChange(block);

			block.setFlags(MemoryBlock.SharedFlag.changed | MemoryBlock.SharedFlag.allocated, false);
		}

		context.sessionData.changedMemoryBlocks.length = 0;
		context.sessionData.newMemoryBlocks.length = 0;
	}

	/// Trashes unmirrored ctime changes - used when there was an error during the compilation
	final void trashCtimeChanges() {
		context.sessionData.changedMemoryBlocks.length = 0;
		context.sessionData.newMemoryBlocks.length = 0;
	}

	void mirrorBlockAllocation(MemoryBlock block) {

	}

	void mirrorBlockDataChange(MemoryBlock block) {

	}

	void mirrorBlockDeallocation(MemoryBlock block) {

	}

public:
	/// Creates a new scope (scopes are stored on a stack)
	/// CodeBuilder scopes are used for destructor generating
	void pushScope(ScopeFlags flags = ScopeFlags.none) {
		scopeStack_ ~= Scope(scopeStack_.length, flags);
		debug scopeStack_[$ - 1].session = context.session;
	}

	/// Destroys the last scope
	/// CodeBuilder scopes are used for destructor generating
	void popScope(bool generateDestructors = true) {
		if (generateDestructors)
			generateScopeExit(scopeStack_[$ - 1]);

		// Free memory allocated by local variables
		foreach_reverse (var; scopeStack_[$ - 1].variables)
			memoryManager.free(var.memoryBlock);

		scopeStack_.length--;
		mirrorCtimeChanges();
	}

	/// Generates destructors for all the scope
	final void generateScopesExit() {
		foreach_reverse (ref s; scopeStack_)
			generateScopeExit(s);
	}

	final void addToScope(DataEntity_LocalVariable var) {
		assert(var.memoryBlock.session == scopeStack_[$ - 1].session, "Local variable created in different session cannot be added to a scope");

		scopeStack_[$ - 1].variables ~= var;
	}

	final void addToScope(DataEntity_LocalVariable[] vars) {
		assert(vars.all!(x => x.memoryBlock.session == scopeStack_[$ - 1].session), "Local variable created in different session cannot be added to a scope");

		scopeStack_[$ - 1].variables ~= vars;
	}

	final DataEntity_LocalVariable[] scopeItems() {
		return scopeStack_[$ - 1].variables;
	}

	/// Returns if the current scope is the root scope
	final bool isRootScope() {
		return scopeStack_.length == 1;
	}

protected:
	void generateScopeExit(ref Scope scope_) {
		foreach_reverse (var; scope_.variables)
			build_dtor(var);

		if (scope_.flags & ScopeFlags.sessionRoot) {
			assert(!this.isCtime);

			foreach (block; context.sessionData.memoryBlocks.byValue) {
				// We ignore memory blocks that are runtime
				// Also we ignore blocks with "doNotMirrorChanges" flag (those are for example memory blocks that store data for mirroring)
				if (block.isRuntime || block.flag(MemoryBlock.Flag.doNotMirrorChanges))
					continue;

				// If the block allocation was not mirrored yet (mirroring would clear the flag), we don't need to mirror deletion
				if (block.flag(MemoryBlock.SharedFlag.allocated))
					continue;

				mirrorBlockDeallocation(block);
			}
		}

	}

protected:
	Scope[] scopeStack_;

protected:
	struct Scope {
		/// Index of the scope in the scopeStack_
		size_t index;
		ScopeFlags flags;
		DataEntity_LocalVariable[] variables;
		debug UIDGenerator.I session;
	}

	enum ScopeFlags {
		/// If the scope can be breaked/continued just using break; (without @label("xx") and break xx;)
		breakableWithoutLabel = 1,
		/// Whether it is possible to use continue statement on the scope
		continuable = breakableWithoutLabel << 1,

		/// The scope is session root scope - exiting it would also exit a session
		sessionRoot = continuable << 1,

		none = 0,
		loop = breakableWithoutLabel | continuable,
	}

	mixin template Build_PrimitiveOperationImpl(string packageName, string resultVar) {
		override void build_primitiveOperation(BackendPrimitiveOperation op, Symbol_Type argT = null, ExprFunction arg1 = null, ExprFunction arg2 = null, ExprFunction arg3 = null) {
			mixin("static import beast.backend.%s.primitiveop;".format(packageName));

			//build_scope( ( cb ) {
			mixin({ //
				import std.array : appender;
				import std.traits : Parameters;

				auto result = appender!string;
				result ~= "final switch( op ) {\n";

				foreach (opStr; __traits(derivedMembers, BackendPrimitiveOperation)) {
					result ~= "case BackendPrimitiveOperation.%s:\n".format(opStr);

					static if (__traits(hasMember, mixin("beast.backend.%s.primitiveop".format(packageName)), "primitiveOp_%s".format(opStr))) {
						mixin("alias func = beast.backend.%s.primitiveop.primitiveOp_%s;".format(packageName, opStr));
						result ~= "{ primitiveOp_%s!( beast.backend.%s.primitiveop.primitiveOp_%s, packageName, \"%s\" )( argT, arg1, arg2, arg3 ); break; }\n".format(Parameters!func.length, packageName, opStr, opStr);
					}
					else
						result ~= "assert( 0, \"primitiveOp %s is not implemented for codebuilder.%s\" );\n".format(opStr, packageName);
				}

				result ~= "}\n";
				return result.data;
			}());
			//} ).inLocalDataScope;

			// Primitive operations aren't supposed to have "results"
			result_ = result_.init;
		}

		private pragma(inline) {
			void primitiveOp_1(alias func, string packageName, string opStr)(Symbol_Type argT = null, ExprFunction arg1 = null, ExprFunction arg2 = null, ExprFunction arg3 = null) {
				func(this);
			}

			void primitiveOp_2(alias func, string packageName, string opStr)(Symbol_Type argT = null, ExprFunction arg1 = null, ExprFunction arg2 = null, ExprFunction arg3 = null) {
				assert(argT, "argT is null %s %s".format(packageName, opStr));
				func(this, argT);
			}

			void primitiveOp_3(alias func, string packageName, string opStr)(Symbol_Type argT = null, ExprFunction arg1 = null, ExprFunction arg2 = null, ExprFunction arg3 = null) {
				assert(argT, "argT is null %s %s".format(packageName, opStr));
				assert(arg1, "arg1 is null %s %s".format(packageName, opStr));

				arg1(this);
				func(this, argT, result_);
			}

			void primitiveOp_4(alias func, string packageName, string opStr)(Symbol_Type argT = null, ExprFunction arg1 = null, ExprFunction arg2 = null, ExprFunction arg3 = null) {
				assert(argT, "argT is null %s %s".format(packageName, opStr));
				assert(arg1, "arg1 is null %s %s".format(packageName, opStr));
				assert(arg2, "arg2 is null %s %s".format(packageName, opStr));

				arg1(this);
				auto arg1v = result_;

				arg2(this);
				func(this, argT, arg1v, result_);
			}

			void primitiveOp_5(alias func, string packageName, string opStr)(Symbol_Type argT = null, ExprFunction arg1 = null, ExprFunction arg2 = null, ExprFunction arg3 = null) {
				assert(argT, "argT is null %s %s".format(packageName, opStr));
				assert(arg1, "arg1 is null %s %s".format(packageName, opStr));
				assert(arg2, "arg2 is null %s %s".format(packageName, opStr));
				assert(arg3, "arg3 is null %s %s".format(packageName, opStr));

				arg1(this);
				auto arg1v = result_;

				arg2(this);
				auto arg2v = result_;

				arg3(this);
				func(this, argT, arg1v, arg2v, result_);
			}
		}
	}

}
