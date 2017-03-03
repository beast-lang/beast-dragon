module beast.backend.cpp.backend;

import beast.backend.toolkit;
import beast.backend.cpp.proxycodebuilder;

final class Backend_Cpp : Backend {

	public:
		override void build( ) {
			scope cb = new CodeBuilder_CppProxy( null );
			auto result = appender!string;

			coreLibrary.module_.buildDefinitionsCode( cb );

			foreach ( m; project.moduleManager.initialModuleList ) {
				// Do not get scared when one symbol code building fails
				m.symbol.buildDefinitionsCode( cb );
			}

			import std.stdio;

			if ( project.configuration.testStdout )
				writeln( result.data );
		}

}
