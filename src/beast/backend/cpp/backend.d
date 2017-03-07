module beast.backend.cpp.backend;

import beast.backend.toolkit;
import beast.backend.common.backend;
import beast.backend.cpp.proxycodebuilder;
import std.array : appender, Appender;
import std.format : formattedWrite;
import beast.backend.cpp.codebuilder;
import std.stdio : writeln;
import std.file : write;

final class Backend_Cpp : Backend {

	public:
		override void build( ) {
			scope cb = new CodeBuilder_CppProxy( null );

			coreLibrary.module_.buildDefinitionsCode( cb );

			foreach ( m; project.moduleManager.initialModuleList ) {
				// Do not get scared when one symbol code building fails
				m.symbol.buildDefinitionsCode( cb );
			}

			// Process memory
			memoryManager.finish( );

			auto code_memory = appender!string;
			foreach ( MemoryBlock block; memoryManager.memoryBlocks ) {
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

			auto result = appender!string;
			result ~= "#define PRIMITIVE_VAL( var, type ) ( *( ( type* )( var ) ) )\n\n";

			result ~= "// TYPES\n";
			result ~= cb.code_types;
			result ~= "\n// MEMORY BLOCKS\n\n";
			result ~= code_memory.data;
			result ~= "\n// DECLARATIONS\n";
			result ~= cb.code_declarations;
			result ~= "\n//DEFINITIONS\n";
			result ~= cb.code_implementations;

			result ~= "void main() {}";

			string filename = "%s.cpp".format( project.configuration.targetFilename );

			filename.write( result.data );

			if ( project.configuration.testStdout )
				writeln( result.data );
		}

}
