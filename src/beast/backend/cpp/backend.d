module beast.backend.cpp.backend;

import beast.backend.toolkit;
import beast.backend.cpp.proxycodebuilder;
import beast.backend.cpp.codebuilder;
import std.format;

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
						"%sunsigned byte %s[%s] = { %s };\n", //
						block.isRuntime ? "" : "const ", CodeBuilder_Cpp.cppIdentifier( block ), //
						block.size, //
						( cast( ubyte[ ] ) block.data[ 0 .. block.size ] ).map!( x => x.to!string ).joiner( ", " ) // Block data
						 );
			}

			import std.stdio;

			if ( project.configuration.testStdout ) {
				writeln( "// TYPES" );
				writeln( cb.code_types );
				writeln( "// MEMORY BLOCKS\n" );
				writeln( code_memory.data );
				writeln( "// DECLARATIONS" );
				writeln( cb.code_declarations );
				writeln( "// DEFINITONS" );
				writeln( cb.code_implementations );
			}
		}

}
