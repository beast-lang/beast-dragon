module beast.backend.common.codebuilder;

import beast.backend.toolkit;

/// Root class for building code with any backend
abstract class CodeBuilder {

public:
	alias StmtFunction = void delegate( );
	alias ExprFunction = Symbol_Variable delegate( );

public:
	/// Builds the "if" construction
	/// Condition has to be of type bool
	abstract void build_if( Symbol_Variable condition, StmtFunction thenBranch, StmtFunction elseBranch )
	in {
		assert( condition.type is coreLibrary.types.Bool );
	}

}
