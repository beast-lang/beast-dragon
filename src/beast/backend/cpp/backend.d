module beast.backend.cpp.backend;

static import std.file;

import beast.backend.common.backend;
import beast.backend.cpp.codebuilder;
import beast.backend.toolkit;
import beast.code.semantic.scope_.root;
import beast.code.hwenv.hwenv;
import beast.core.error.error;
import beast.core.project.configuration;
import std.array : appender, Appender, replace;
import std.format : formattedWrite;
import std.path : absolutePath;
import std.process : executeShell;
import std.stdio : writeln;
import std.bigint;

final class Backend_Cpp : Backend {

public:
	override void build() {
		auto entryFunctionCallCB = scoped!CodeBuilder_Cpp(1);

		// Must be done in a thread because of task guards
		taskManager.imminentIssueJob({ //
			with (memoryManager.session(SessionPolicy.watchCtChanges)) {
				auto entryModule = project.entryModule.symbol.dataEntity;
				auto _sgd = new RootDataScope(entryModule).scopeGuard;
				entryModule.expectResolveIdentifier(ID!"main").resolveCall(null, true).buildCode(entryFunctionCallCB);
			}
		});

		// Process memory
		taskManager.waitForEverythingDone();
		memoryManager.finish();

		debug finished_ = true;

		auto code_memory = appender!string;
		auto code_memorydecl = appender!string;

		size_t prevPtr = 0;
		debug MemoryBlock prevBlock;
		foreach (MemoryBlock block; memoryManager.memoryBlocks) {
			assert(block.startPtr.val > prevPtr);
			assert(block.isCtime || memoryManager.nextPointer(block.startPtr - 1).isNull || memoryManager.nextPointer(block.startPtr - 1) >= block.endPtr, "Block %s-%s is runtime, but found pointer at %s".format(block.startPtr, block.endPtr, memoryManager.nextPointer(block.startPtr - 1)));

			prevPtr = block.startPtr.val;
			debug prevBlock = block;

			string identifier = CodeBuilder_Cpp.cppIdentifier(block);
			size_t arraySize = (block.size + hardwareEnvironment.pointerSize - 1) / hardwareEnvironment.pointerSize;

			code_memorydecl.formattedWrite("extern uintptr_t %s[%s];\n", identifier, arraySize);
			code_memory.formattedWrite("uintptr_t %s[%s] = { ", identifier, arraySize);

			//assert( ulong.sizeof >= hardwareEnvironment.pointerSize );
			if (block.isCtime) {
				BigInt data = block.data[0];
				auto mem = memoryManager;

				MemoryPtr nextPtr = memoryManager.nextPointer(block.startPtr - 1);
				size_t nextPtrOffset = nextPtr.val - block.startPtr.val + hardwareEnvironment.pointerSize;
				size_t i = 1;
				foreach (b; block.data[1 .. block.size]) {
					if (i % hardwareEnvironment.pointerSize == 0) {
						if (i == nextPtrOffset) {
							code_memory.formattedWrite("(uintptr_t) %s, ", CodeBuilder_Cpp.memoryPtrIdentifier(nextPtr.readMemoryPtr));
							nextPtr = memoryManager.nextPointer(block.startPtr + i - 1);
							nextPtrOffset = nextPtr.val - block.startPtr.val + hardwareEnvironment.pointerSize;
						}
						else
							code_memory.formattedWrite("0x%s, ", data.toHex.filter!(x => x != '_'));

						data = 0;
					}

					data += (cast(ulong) b) << (i * 8);
					i++;
				}

				if (i == nextPtrOffset)
					code_memory.formattedWrite("(uintptr_t) %s };\n", CodeBuilder_Cpp.memoryPtrIdentifier(nextPtr.readMemoryPtr));
				else
					code_memory.formattedWrite("0x%s };\n", data.toHex.filter!(x => x != '_'));
			}
			else
				code_memory.formattedWrite("0 };\n");
		}

		if (wereErrors)
			return;

		auto result = appender!string;
		result ~= "#define VAL( var, type ) ( *( ( type* )( var ) ) )\n";
		result ~= "#define TYPEDEF( id, size ) typedef struct { uintptr_t data[ size ]; } id\n";
		result ~= "#define PARAM( expr, type ) ( ( type* )( expr ) )\n";
		result ~= "#define DEREF( expr ) ( *( ( uintptr_t ** )( expr ) ) )\n";
		result ~= "#define OFFSET( expr, offset ) ( ( uintptr_t* ) ( ( ( uint8_t* ) expr ) + offset ) )\n";
		result ~= "#define CTMEM\n\n";
		result ~= "#include <stdint.h>\n";
		result ~= "#include <stdio.h>\n";
		result ~= "#include <string.h>\n";
		result ~= "#include <stdlib.h>\n";
		result ~= "#include <assert.h>\n";
		result ~= "\n";
		result ~= "uintptr_t *ctimeStack[ 1024 * 1024 ];\n";
		result ~= "size_t ctimeStackSize = 0;\n";
		result ~= "\n";

		result ~= "// TYPES\n";
		foreach (cb; codebuilders_)
			result ~= cb.code_types;

		result ~= "\n// MEMORY BLOCKS DECLARATIONS\n";
		result ~= code_memorydecl.data;

		result ~= "\n// MEMORY BLOCKS\n";
		result ~= code_memory.data;

		result ~= "\n// DECLARATIONS\n";
		foreach (cb; codebuilders_)
			result ~= cb.code_declarations;
		result ~= "\n//DEFINITIONS\n";
		foreach (cb; codebuilders_)
			result ~= cb.code_implementations;

		// Main function
		{
			result ~= "int main() {\n";
			result ~= "\tsize_t ctimeStackBP = ctimeStackSize;\n";
			result ~= "\tif( sizeof( void* ) != %s ) {\n".format(hardwareEnvironment.pointerSize);
			result ~= "\t\tfprintf( stderr, \"Beast compiler considered pointer size %s but C compiler used %%zu\", sizeof(void*) );\n".format(hardwareEnvironment.pointerSize);
			result ~= "\t\texit( -1 );\n";
			result ~= "\t}\n";

			foreach (cb; initCodebuilders_) {
				assert(!cb.code_types);
				assert(!cb.code_declarations);
				result ~= cb.code_implementations;
			}

			result ~= entryFunctionCallCB.code_implementations;
			result ~= "\treturn 0;\n";
			result ~= "}\n";
		}

		string filename = "%s.cpp".format(project.configuration.targetFilename);

		if (project.configuration.outputCodeToStdout)
			writeln(result.data);

		std.file.write(filename, result.data);

		if (!wereErrors && project.configuration.stopOnPhase >= ProjectConfiguration.StopOnPhase.outputgen) {
			string command = project.configuration.compileCommand;
			command = command.replace("%COMPILER%", project.configuration.cppCompiler);
			command = command.replace("%SOURCE%", filename);
			command = command.replace("%TARGET%", project.configuration.targetFilename);

			auto compileResult = command.executeShell();

			benforce(compileResult.status == 0, E.cppCompilationFailed, "Failed to compile the C++ code:\n\t%s".format(compileResult.output.replace("\n", "\n\t")));
		}
	}

	override CodeBuilder spawnFunctionCodebuilder() {
		return new CodeBuilder_Cpp();
	}

public:
	override void buildInitCode(CodeBuilder.StmtFunction func) {
		debug assert(!finished_);

		auto cb = new CodeBuilder_Cpp(1);
		cb.build_scope(func);

		synchronized (this)
			initCodebuilders_ ~= cb;
	}

public:
	/// Includes definition of given runtime function in the output code
	override void buildRuntimeFunction(Symbol_RuntimeFunction func) {
		debug assert(!finished_);

		auto cb = new CodeBuilder_Cpp();
		func.buildCode(cb);
		synchronized (this)
			codebuilders_ ~= cb;
	}

	/// Includes declaration of given type in the output code (no member functions, only the type itself)
	override void buildType(Symbol_Type type) {
		debug assert(!finished_);

		auto cb = new CodeBuilder_Cpp();
		cb.build_typeDefinition(type);
		synchronized (this)
			codebuilders_ ~= cb;
	}

private:
	/// Codebuilders with function codes etc
	CodeBuilder_Cpp[] codebuilders_;
	/// Codebuilders containing code that should be executed before main function
	CodeBuilder_Cpp[] initCodebuilders_;
	debug bool finished_;

}
