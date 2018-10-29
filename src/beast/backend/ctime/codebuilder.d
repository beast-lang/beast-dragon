module beast.backend.ctime.codebuilder;

import beast.backend.toolkit;
import beast.code.entity.scope_.local;
import beast.backend.interpreter.interpreter;
import beast.util.uidgen;
import beast.corelib.type.reference;
import std.algorithm : count;
import beast.core.ctxctimeguard;

/// "CodeBuilder" that executes data at compile time
/// Because of its result caching, always use each instance of this codebuilder in one task context only!
final class CodeBuilder_Ctime : CodeBuilder {

public:
	this() {
		debug jobId_ = context.jobId;
	}

public:
	override bool isCtime() {
		return true;
	}

public:
	/// Result of the last "built" (read "executed") code
	CTExecResult result() {
		debug {
			// assert( result_ ); Executing a code can return void
			assert(context.jobId == jobId_, "CodeBuilder used in multiple threads (created in %s, current %s)".format(jobId_, context.jobId));

			debug if (result_) {
				auto block = memoryManager.findMemoryBlock(result_);
				assert(block && block.isCtime);
			}
		}

		return CTExecResult(this);
	}

public:
	override void build_localVariableDefinition(DataEntity_LocalVariable var) {
		var.allocate(true);
		addToScope(var);
	}

public: // Expression related build commands
	override void build_memoryAccess(MemoryPtr pointer) {
		debug assert(context.jobId == jobId_);

		MemoryBlock b = memoryManager.findMemoryBlock(pointer);
		benforce(b.isCtime, E.valueNotCtime, "Variable %s is not ctime".format(b.identificationString));

		result_ = pointer;
	}

	override void build_offset(ExprFunction expr, size_t offset) {
		expr(this);
		memoryManager.checkNullptr(result_);
		result_.val += offset;
	}

public:
	override void build_functionCall(Symbol_RuntimeFunction function_, DataEntity parentInstance, DataEntity[] arguments) {
		assert(arguments.length == function_.parameters.count!(x => !x.isConstValue));

		auto __cgd = ContextCtimeGuard(true);

		// We execute the runtime function using the interpreter
		debug (identificationLocals) string functionIdentification = function_.identificationString;

		debug (interpreter) {
			import std.stdio : writefln;

			writefln("== PREPARE CALL");
		}

		MemoryPtr result;
		if (function_.returnType !is coreType.Void) {
			auto resultVar = new DataEntity_TmpLocalVariable(function_.returnType);
			build_localVariableDefinition(resultVar);

			result = resultVar.memoryPtr;

			debug (interpreter)
				writefln("result: %s (%s)", result, function_.returnType.identificationString);
		}

		MemoryPtr ctx;
		if (function_.declarationType == Symbol.DeclType.memberFunction) {
			assert(parentInstance);
			parentInstance.buildCode(this);
			ctx = result_;

			debug (interpreter)
				writefln("ctx: %s (%s?) = %s", ctx, parentInstance.dataType.identificationString, result_);
		}

		MemoryPtr[] args;
		foreach (param; function_.parameters.filter!(x => !x.isConstValue)) {
			auto argVar = new DataEntity_TmpLocalVariable(param.dataType);
			build_localVariableDefinition(argVar);
			build_copyCtor(argVar, arguments[param.runtimeIndex]);

			assert(args.length == param.runtimeIndex);
			args ~= argVar.memoryPtr;

			debug (interpreter)
				writefln("arg%s (rt %s): %s (%s) = %s", param.index, param.runtimeIndex, argVar.memoryPtr, param.dataType.identificationString, argVar.valueIdentificationString);
		}

		Interpreter.executeFunction(function_, result, ctx, args);

		result_ = result;
	}

	override void build_parameterAccess(ExpandedFunctionParameter param) {
		berror(E.valueNotCtime, "Parameter %s is not @ctime".format(param.identificationString));
	}

	override void build_dereference(ExprFunction arg) {
		arg(this);

		debug (ctime) {
			import std.stdio : writefln;

			writefln("CTIME dereference %s (=%s)", result_, result_.readMemoryPtr);
		}

		result_ = result_.readMemoryPtr;
	}

	mixin Build_PrimitiveOperationImpl!("ctime", "result_");

public:
	override void build_scope(StmtFunction body_) {
		pushScope();
		body_(this);
		popScope();
	}

	override void build_if(ExprFunction condition, StmtFunction thenBranch, StmtFunction elseBranch) {
		pushScope();

		condition(this);
		bool result = result_.readPrimitive!bool;

		if (result) {
			pushScope();
			thenBranch(this);
			popScope();
		}
		else if (elseBranch) {
			pushScope();
			elseBranch(this);
			popScope();
		}

		popScope();
		result_ = MemoryPtr();
	}

	override void build_return(DataEntity returnValue) {
		berror(E.invalidReturn, "Cannot return from a runtime function at compile time");
	}

public:
	override void popScope(bool generateDestructors = true) {
		// Result might be f-ked around because of destructors
		auto result = result_;

		super.popScope(generateDestructors);

		result_ = result_;
	}

public:
	final string identificationString() {
		return "codebuilder.@ctime";
	}

package:
	debug UIDGenerator.I jobId_;
	MemoryPtr result_;

}

struct CTExecResult {

public:
	pragma(inline) MemoryPtr value() {
		return codeBuilder_.result_;
	}

	/// Keeps the result value until session and and returns it
	pragma(inline) MemoryPtr keepUntilSessionEnd() {
		return value();
	}

	/// Keeps the result value forever (marks it doNotGCAtSessionEnd) and returns it
	pragma(inline) MemoryPtr keepForever() {
		value.block.markDoNotGCAtSessionEnd();
		return value();
	}

	/// Destroys the result
	pragma(inline) void destroy() {
		codeBuilder_.popScope();
	}

public:
	/// Returns local variables of the root scope (the scope that holds result)
	pragma(inline) DataEntity_LocalVariable[] scopeItems() {
		assert(codeBuilder_.isRootScope);
		return codeBuilder_.scopeItems;
	}

private:
	CodeBuilder_Ctime codeBuilder_;

}
