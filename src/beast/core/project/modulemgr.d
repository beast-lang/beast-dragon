module beast.core.project.modulemgr;

import beast.toolkit;
import beast.core.project.codelocation;
import beast.code.lex.identifier;
import beast.core.project.module_;

/// Class that handles mapping modules on files in the filesystem (eventually stdin or whatever)
final class ModuleManager {

public:
	/// Initializes the manager for usage (prepares initial module list)
	void initialize() {
		initialModuleList_ = getInitialModuleList();

		foreach (Module m; initialModuleList_) {
			benforce(m.identifier !in moduleList_, E.moduleNameConflict, "Modules '" ~ m.absoluteFilePath ~ "' and '" ~ moduleList_[m.identifier].absoluteFilePath ~ "' have both same identifier '" ~ m.identifier.str ~ "'");
			moduleList_[m.identifier] = m;
		}
	}

public:
	/// Returns module based on identifier. The module can be added to the project by demand.
	final Module getModule(ExtendedIdentifier id) {
		synchronized (this) {
			// If the module is already in the project, return it
			if (auto result = id in moduleList_)
				return *result;

			// Otherwise try adding it to the project
			// TODO: Implement searching in include directories

			berror(E.moduleNotFound, "Module %s not found".format(id.str));
			//berror( E.notImplemented, "Lazy including modules not implemented" );
			assert(0);
		}
	}

	final Module[] initialModuleList() {
		return initialModuleList_;
	}

protected:
	Module[] getInitialModuleList() {
		import std.file : dirEntries, SpanMode;
		import std.path : asRelativePath, baseName, absolutePath, stripExtension, pathSplitter;

		Module[] result;

		// Scan source directories
		foreach (string sourceDir; project.configuration.sourceDirectories) {
			auto fileList = sourceDir.dirEntries("*.be", SpanMode.depth);
			benforce!(ErrorSeverity.warning)(!fileList.empty, E.noModulesInSourceDirectory, "There are no modules in source directory '" ~ sourceDir ~ "'");

			foreach (string file; fileList) {
				// For each .be file in source directories, create a module
				// Identifier of the module should correspon to the path from source directory
				ExtendedIdentifier extId = ExtendedIdentifier(file.asRelativePath(sourceDir).array.stripExtension.pathSplitter.map!(x => Identifier(cast(string) x)).array);

				// Test if the identifier is valid
				foreach (id; extId)
					benforce(id.str.isValidModuleOrPackageIdentifier, E.invalidModuleIdentifier, "Identifier '%s' of module '%s' (%s) is not valid.".format(id.str, extId.str, file.absolutePath(sourceDir)));

				Module m = new Module(Module.CTOR_FromFile(), file.absolutePath(sourceDir), extId);
				result ~= m;
			}
		}

		// Add explicit source files
		foreach (string file; project.configuration.sourceFiles) {
			ExtendedIdentifier extId = ExtendedIdentifier([Identifier(file.baseName.stripExtension)]);

			// Test if the identifier is valid (explicit source files have only one identifier in extid)
			benforce(extId[0].str.isValidModuleOrPackageIdentifier, E.invalidModuleIdentifier, "Module identifier '%s' (%s) is not valid.".format(extId.str, file));

			Module m = new Module(Module.CTOR_FromFile(), file.absolutePath, extId);
			result ~= m;
		}

		return result;
	}

private:
	Module[ExtendedIdentifier] moduleList_;
	Module[] initialModuleList_;

}
