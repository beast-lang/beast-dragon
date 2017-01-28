module beast.project.modulemgr.standard;

import beast.toolkit;
import beast.project.modulemgr.modulemgr;
import beast.project.bmodule;
import beast.lex.identifier;
import std.path;
import std.file;
import std.algorithm;
import core.runtime;

final class StandardModuleManager : ModuleManager {

protected:
	override Module _getModule( ExtendedIdentifier id, CodeLocation codeLocation ) {
		berror( CodeLocation.none, BError.moduleImportFail, "Module '" ~ id.str ~ "' is not part of the project" );
		assert( 0 );
	}

	override Module[ ] getInitialModuleList( ) {
		Module[ ] result;

		foreach ( string filename; context.project.configuration.sourceDirectories.map!( x => x.dirEntries( "*.be", SpanMode.depth ).map!( y => y.absolutePath( x ) ) ).joiner ) {
			import std.stdio;

			writeln( filename );
		}

		return result;
	}

}
