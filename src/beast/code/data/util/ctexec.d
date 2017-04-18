module beast.code.data.util.ctexec;

import beast.code.data.toolkit;
import beast.code.data.util.proxy;
import beast.backend.common.primitiveop;

final static class DataEntity_CtExecProxy : ProxyDataEntity {

	public:
		this( DataEntity sourceEntity ) {
			super( sourceEntity, MatchLevel.fullMatch );
		}

	public:
		override bool isCtime( ) {
			return true;
		}

	public:
		override void buildCode( CodeBuilder cb ) {
			auto result = sourceEntity_.ctExec();

			// Result might be void -> no memory access
			if( result )
				cb.build_memoryAccess( result );
		}
}
