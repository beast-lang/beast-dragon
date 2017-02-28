module beast.backend.cpp.backend;

import beast.backend.toolkit;
import beast.backend.cpp.codebuilder;

final class Backend_Cpp : Backend {

public:
	override void build( ) {
		scope cb = new CodeBuilder_Cpp( null );

		coreLibrary.module_.buildDefinitionsCode( cb );

		foreach ( m; project.moduleManager.initialModuleList )
			m.symbol.buildDefinitionsCode( cb );

		import std.stdio;
		writeln( cb.result );
	}

}
