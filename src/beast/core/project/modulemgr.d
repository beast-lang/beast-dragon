module beast.core.project.modulemgr;

import beast.toolkit;
import beast.code.module_;
import std.file;
import std.path;
import std.algorithm;
import std.array;

/// Class that handles mapping modules on files in the filesystem (eventually stdin or whatever)
final class ModuleManager {

public:
	/// Initializes the manager for usage (prepares initial module list)
	void initialize( ) {
		initialModuleList_ = getInitialModuleList( );
		
		foreach ( Module m; initialModuleList_ ) {
			benforce( m.identifier !in moduleList_, E.moduleNameConflict, "Modules '" ~ m.absoluteFilePath ~ "' and '" ~ moduleList_[ m.identifier ].absoluteFilePath ~ "' have both same identifier '" ~ m.identifier.str ~ "'" );
			moduleList_[ m.identifier ] = m;
		}
	}

public:
	/// Returns module based on identifier. The module can be added to the project by demand.
	final Module getModule( ExtendedIdentifier id, CodeLocation codeLocation ) {
		synchronized ( this ) {
			// If the module is already in the project, return it
			auto _in = id in moduleList_;
			if ( _in )
				return *_in;

			// TODO: std library injection

			// Otherwise try adding it to the project
			// TODO: Implement searching in include directories

			berror( E.unimplemented, "" );
			assert( 0 );
		}
	}

	@property final Module[ ] initialModuleList( ) {
		return initialModuleList_;
	}

protected:
	Module[ ] getInitialModuleList( ) {
		Module[ ] result;

		// Scan source directories
		foreach ( string sourceDir; context.project.configuration.sourceDirectories ) {
			auto fileList = sourceDir.dirEntries( "*.be", SpanMode.depth );
			benforce!( ErrorSeverity.warning )( !fileList.empty, E.noModulesInSourceDirectory, "There are no modules in source directory '" ~ sourceDir ~ "'" );

			foreach ( string file; fileList ) {
				// For each .be file in source directories, create a module
				// Identifier of the module should correspon to the path from source directory
				ExtendedIdentifier extId = ExtendedIdentifier( file.asRelativePath( sourceDir ).array.stripExtension.pathSplitter.map!( x => Identifier.obtain( cast( string ) x ) ).array );

				// Test if the identifier is valid
				foreach ( id; extId )
					benforce( id.str.isValidModuleOrPackageIdentifier, E.invalidModuleIdentifier, "Identifier '" ~ id.str ~ "' of module '" ~ extId.str ~ "' (" ~ file.absolutePath( sourceDir ) ~ ") is not a valid module identifier." );

				Module m = new Module( Module.CTOR_FromFile( ), file.absolutePath( sourceDir ), extId );
				result ~= m;

				// Force taskGuard to obtain data for the module
				context.taskManager.issueJob( { m.parsingData; } );
			}
		}

		foreach ( string file; context.project.configuration.sourceFiles ) {
			ExtendedIdentifier extId = ExtendedIdentifier( [ Identifier.obtain( file.baseName.stripExtension ) ] );

			// Test if the identifier is valid
			benforce( extId[ 0 ].str.isValidModuleOrPackageIdentifier, E.invalidModuleIdentifier, "Identifier '" ~ extId.str ~ "' of module '" ~ extId.str ~ "' (" ~ file ~ ") is not a valid module identifier." );

			Module m = new Module( Module.CTOR_FromFile( ), file.absolutePath, extId );
			result ~= m;

			// Force taskGuard to obtain symbol for the module
			context.taskManager.issueJob( { m.symbol; } );
		}

		return result;
	}

private:
	Module[ const ExtendedIdentifier ] moduleList_;
	Module[ ] initialModuleList_;

}
