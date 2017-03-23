module beast.backend.cpp.backend;

import beast.backend.common.backend;
import beast.backend.cpp.codebuilder;
import beast.backend.toolkit;
import beast.core.error.error;
import std.array : appender, Appender;
import std.file : write;
import std.format : formattedWrite;
import std.stdio : writeln;
import std.path : absolutePath;

final class Backend_Cpp : Backend {

	public:
		override void build( ) {
			// Process memory
			taskManager.waitForEverythingDone( );
			memoryManager.finish( );

			finished_ = true;

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

			if ( wereErrors )
				return;

			auto result = appender!string;
			result ~= "#define VAL( var, type ) ( *( ( type* )( var ) ) )\n";
			result ~= "#include <stdint.h>\n";
			result ~= "\n";

			result ~= "// TYPES\n";
			foreach ( cb; codebuilders_ )
				result ~= cb.code_types;
			result ~= "\n// MEMORY BLOCKS\n\n";
			result ~= code_memory.data;
			result ~= "\n// DECLARATIONS\n";
			foreach ( cb; codebuilders_ )
				result ~= cb.code_declarations;
			result ~= "\n//DEFINITIONS\n";
			foreach ( cb; codebuilders_ )
				result ~= cb.code_implementations;

			result ~= "void main() {}";

			string filename = "%s.cpp".format( project.configuration.targetFilename );

			filename.write( result.data );

			if ( project.configuration.testStdout )
				writeln( result.data );
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
