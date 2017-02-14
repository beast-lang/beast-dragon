module beast.backend.common.codebuilder;

import beast.backend.toolkit;
import beast.code.data.toolkit;

/// Root class for building code with any backend
abstract class CodeBuilder {

public:
	alias StmtFunction = void delegate( );
	alias ExprFunction = DataEntity delegate( );

public:
	/// Builds the "if" construction
	/// Condition has to be of type bool
	abstract void build_if( DataEntity condition, StmtFunction thenBranch, StmtFunction elseBranch );
	
}
