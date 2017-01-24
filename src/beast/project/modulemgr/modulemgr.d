module beast.project.modulemgr.modulemgr;

import beast.lex.identifier;

abstract class ModuleManager {

public:
	/// Identifiers of root packages
	abstract @property Identifier[ ] rootPackages( );

}
