module beast.backend.cpp.backend;

static import std.file;

import beast.backend.common.backend;
import beast.backend.cpp.codebuilder;
import beast.backend.toolkit;
import beast.code.data.scope_.root;
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

			debug finished_ = true;

			auto code_memory = appender!string;
			auto code_memorydecl = appender!string;

			size_t prevPtr = 0;
			debug MemoryBlock prevBlock;
			foreach ( MemoryBlock block; memoryManager.memoryBlocks ) {
				assert( block.startPtr.val > prevPtr );

				prevPtr = block.startPtr.val;
				debug prevBlock = block;

				string identifier = CodeBuilder_Cpp.cppIdentifier( block );
				size_t arraySize = ( block.size + hardwareEnvironment.pointerSize - 1 ) / hardwareEnvironment.pointerSize;

				if( block.isReferenced )
				code_memory.formattedWrite( "/* REFERENCED */ " );

				code_memorydecl.formattedWrite( "extern uintptr_t %s[%s];\n", identifier, arraySize );
				code_memory.formattedWrite( "uintptr_t %s[%s] = { ", identifier, arraySize );

				BigInt data = block.data[ 0 ];
				auto mem = memoryManager;

				size_t nextPtr = memoryManager.nextPointer( block.startPtr - 1 ).val - block.startPtr.val + hardwareEnvironment.pointerSize;
				size_t i = 1;
				foreach ( b; block.data[ 1 .. block.size ] ) {
					if ( i % hardwareEnvironment.pointerSize == 0 ) {
						if ( i == nextPtr ) {
							code_memory.formattedWrite( "(uintptr_t) %s, ", CodeBuilder_Cpp.memoryPtrIdentifier( ( block.startPtr + i - hardwareEnvironment.pointerSize ).readMemoryPtr ) );
							nextPtr = memoryManager.nextPointer( block.startPtr + i - 1 ).val - block.startPtr.val + hardwareEnvironment.pointerSize;
						}
						else
							code_memory.formattedWrite( "0x%x, ", data );

						data = 0;
					}

					data += b << ( i * 8 );
					i++;
				}

				if ( i == nextPtr )
					code_memory.formattedWrite( "(uintptr_t) %s };\n", CodeBuilder_Cpp.memoryPtrIdentifier( ( block.startPtr + i - hardwareEnvironment.pointerSize ).readMemoryPtr ) );
				else
					code_memory.formattedWrite( "0x%x };\n", data );
			}

			if ( wereErrors )
				return;

			auto result = appender!string;
			result ~= "#define VAL( var, type ) ( *( ( type* )( var ) ) )\n";
			result ~= "#define CTMEM\n\n";
			result ~= "#include <stdint.h>\n";
			result ~= "#include <stdio.h>\n";
			result ~= "#include <string.h>\n";
			result ~= "#include <stdlib.h>\n";
			result ~= "#include <assert.h>\n";
			result ~= "\n";

			result ~= "// TYPES\n";
			foreach ( cb; codebuilders_ )
				result ~= cb.code_types;

			result ~= "\n// MEMORY BLOCKS DECLARATIONS\n";
			result ~= code_memorydecl.data;

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
				result ~= "if( sizeof( void* ) != %s ) { fprintf( stderr, \"Beast compiler considered pointer size %s but C compiler used %%s\", sizeof(void*) ); exit( -1 ); }\n".format( hardwareEnvironment.pointerSize, hardwareEnvironment.pointerSize );

				foreach ( cb; initCodebuilders_ ) {
					assert( !cb.code_types );
					assert( !cb.code_declarations );
					result ~= cb.code_implementations;
				}

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
		override void buildInitCode( CodeBuilder.StmtFunction func ) {
			debug assert( !finished_ );

			auto cb = new CodeBuilder_Cpp( 1 );
			cb.build_scope( func );

			synchronized ( this )
				initCodebuilders_ ~= cb;
		}

	public:
		/// Includes definition of given runtime function in the output code
		override void buildRuntimeFunction( Symbol_RuntimeFunction func ) {
			debug assert( !finished_ );

			auto cb = new CodeBuilder_Cpp( );
			func.buildCode( cb );
			synchronized ( this )
				codebuilders_ ~= cb;
		}

		/// Includes declaration of given type in the output code (no member functions, only the type itself)
		override void buildType( Symbol_Type type ) {
			debug assert( !finished_ );

			auto cb = new CodeBuilder_Cpp( );
			cb.build_typeDefinition( type );
			synchronized ( this )
				codebuilders_ ~= cb;
		}

	private:
		/// Codebuilders with function codes etc
		CodeBuilder_Cpp[ ] codebuilders_;
		/// Codebuilders containing code that should be executed before main function
		CodeBuilder_Cpp[ ] initCodebuilders_;
		debug bool finished_;

}
