module beast.code.semantic.util.ctexec;

import beast.code.semantic.toolkit;
import beast.code.semantic.util.proxy;
import beast.backend.common.primitiveop;

final static class DataEntity_CtExecProxy : ProxyDataEntity {

public:
	this(DataEntity sourceEntity) {
		super(sourceEntity, MatchLevel.fullMatch);
	}

public:
	override bool isCtime() {
		return true;
	}

public:
	override void buildCode(CodeBuilder cb) {
		// TODO: Better, this way it does not work well
		// benforce!( ErrorSeverity.warning )( !cb.isCtime, E.duplicitModification, "@ctime is redundant" );

		if (cb.isCtime)
			sourceEntity_.buildCode(cb);

		// Result might be void -> no memory access
		else {
			auto ctexec = sourceEntity_.ctExec();

			if (auto result = ctexec.keepUntilSessionEnd)
				cb.build_memoryAccess(result);

			cb.addToScope(ctexec.scopeItems);
		}
	}
}
