module beast.backend.cpp.backend;

import beast.backend.common.backend;
import beast.backend.cpp.codebuilder;
import beast.backend.toolkit;
import beast.core.error.error;
import std.array : appender, Appender, replace;
static import std.file;
import std.format : formattedWrite;
import std.stdio : writeln;
import std.path : absolutePath;
import std.process : executeShell;
import beast.core.project.configuration;
import beast.code.data.scope_.root;

final class Backend_Cpp : Backend {

	public:
		override void build( ) {
			auto entryFunctionCallCB = scoped!CodeBuilder_Cpp( 1 );

			// Must be done in a thread because of task guards
			taskManager.imminentIssueJob( { //
				auto entryModule = project.entryModule.symbol.dataEntity;
				
				auto _sgd = scopeGuard( new RootDataScope( entryModule ) );
				entryModule.expectResolveIdentifier( ID!"main" ).resolveCall( null, true ).buildCode( entryFunctionCallCB );
			} );

			// Process memory
			taskManager.waitForEverythingDone( );
			memoryManager.finish( );

			finished_ = true;

			auto code_memory = appender!string;

			size_t prevPtr = 0;
			debug MemoryBlock prevBlock;
			foreach ( MemoryBlock block; memoryManager.memoryBlocks ) {
				assert( block.startPtr.val > prevPtr );

				prevPtr = block.startPtr.val;
				debug prevBlock = block;

				if ( !block.isReferenced )
					continue;

				if ( block.isLocal ) // TODO: this should never happen
					continue;

				code_memory.formattedWrite(  //
						"unsigned char %s[%s] = { %s };\n", //
						//block.isRuntime ? "" : "const ", // Constness not implemented yet
						CodeBuilder_Cpp.cppIdentifier( block ), //
						block.size, //
						( cast( ubyte[ ] ) block.data[ 0 .. block.size ] ).map!( x => x.to!string ).joiner( ", " ) // Block data
						 );
			}

			if ( wereErrors )
				return;

			auto result = appender!string;
			result ~= "#define VAL( var, type ) ( *( ( type* )( var ) ) )\n\n";
			result ~= "#include <stdint.h>\n";
			result ~= "#include <stdio.h>\n";
			result ~= "#include <string.h>\n";
			result ~= "#include <stdlib.h>\n";
			result ~= "\n";

			result ~= "// TYPES\n";
			foreach ( cb; codebuilders_ )
				result ~= cb.code_types;
			result ~= "\n// MEMORY BLOCKS\n";
			result ~= code_memory.data;
			result ~= "\n// DECLARATIONS\n";
			foreach ( cb; codebuilders_ )
				result ~= cb.code_declarations;
			result ~= "\n//DEFINITIONS\n";
			foreach ( cb; codebuilders_ )
				result ~= cb.code_implementations;

			// Main function
			{
				result ~= "int main() {\n";
				result ~= entryFunctionCallCB.code_implementations;
				result ~= "\treturn 0;\n";
				result ~= "}\n";
			}

			string filename = "%s.cpp".format( project.configuration.targetFilename );

			if ( project.configuration.outputCodeToStdout )
				writeln( result.data );

			std.file.write( filename, result.data );

			if ( !wereErrors && project.configuration.stopOnPhase >= ProjectConfiguration.StopOnPhase.outputgen ) {
				string command = project.configuration.compileCommand;
				command = command.replace( "%COMPILER%", project.configuration.cppCompiler );
				command = command.replace( "%SOURCE%", filename );
				command = command.replace( "%TARGET%", project.configuration.targetFilename );

				auto compileResult = command.executeShell( );

				benforce( compileResult.status == 0, E.cppCompilationFailed, "Failed to compile the C++ code:\n\t%s".format( compileResult.output.replace( "\n", "\n\t" ) ) );
			}
		}

		override CodeBuilder spawnFunctionCodebuilder( ) {
			return new CodeBuilder_Cpp( );
		}

	public:
		/// Includes definition of given runtime function in the output code
		override void buildRuntimeFunction( Symbol_RuntimeFunction func ) {
			assert( !finished_ );

			auto cb = new CodeBuilder_Cpp( );
			func.buildCode( cb );
			synchronized ( this )
				codebuilders_ ~= cb;
		}

		/// Includes declaration of given type in the output code (no member functions, only the type itself)
		override void buildType( Symbol_Type type ) {
			assert( !finished_ );

			auto cb = new CodeBuilder_Cpp( );
			cb.build_typeDefinition( type );
			synchronized ( this )
				codebuilders_ ~= cb;
		}

	private:
		CodeBuilder_Cpp[ ] codebuilders_;
		debug bool finished_;

}
