module beast.backend.ctime.codebuilder;

import beast.backend.toolkit;

final class CodeBuilder_Ctime : CodeBuilder {

public:
	override void build_if( DataEntity condition, StmtFunction thenBranch, StmtFunction elseBranch ) {
		assert( condition.dataType is coreLibrary.types.Bool );

	}

}
