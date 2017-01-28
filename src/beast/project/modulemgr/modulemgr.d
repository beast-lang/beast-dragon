module beast.project.modulemgr.modulemgr;

import beast.toolkit;
import beast.project.bmodule;

/// Class that handles mapping modules on files in the filesystem (eventually stdin or whatever)
abstract class ModuleManager {

public:
	/// Returns names of modules that are known to be in the project from the beginning. Final module list included in the project might change because of automatic includes (in project, std libraries, ...).
	abstract ExtendedIdentifier[ ] intialModuleList( );

	/// Returns module based on identifier. The module can be added to the project by demand.
	final Module getModule( ExtendedIdentifier id ) {
		synchronized ( this ) {
			// If the module is already in the project, return it
			auto _in = id in moduleList_;
			if ( _in )
				return *_in;

			// Otherwise try adding it to the project
			Module mod = _getModule( id );
			moduleList_[ id ] = mod;
			return mod;
		}
	}

protected:
	abstract Module _getModule( ExtendedIdentifier id );

private:
	Module[ ExtendedIdentifier ] moduleList_;

}
