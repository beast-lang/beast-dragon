module beast.project.modulemgr.modulemgr;

import beast.toolkit;
import beast.project.bmodule;

/// Class that handles mapping modules on files in the filesystem (eventually stdin or whatever)
abstract class ModuleManager {

public:
	/// Initializes the manager for usage (prepares initial module list)
	void initialize( ) {
		initialModuleList_ = getInitialModuleList();
		foreach( Module m; initialModuleList_ )
			moduleList_[ m.identifier ] = m;
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
			Module mod = _getModule( id, codeLocation );
			moduleList_[ id ] = mod;
			return mod;
		}
	}

	@property final Module[] initialModuleList() {
		return initialModuleList_;
	}

protected:
	abstract Module _getModule( ExtendedIdentifier id, CodeLocation codeLocation );
	abstract Module[] getInitialModuleList();

private:
	Module[ const ExtendedIdentifier ] moduleList_;
	Module[ ] initialModuleList_;

}
