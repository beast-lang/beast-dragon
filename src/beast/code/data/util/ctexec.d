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
			auto ctexec = sourceEntity_.ctExec( );

			// Add local variables that resulted from building ctexec to the current scope so their destruction gets mirrored when the scope ends
			cb.addToScope( ctexec.scopeVariables );

			// Result might be void -> no memory access
			if ( ctexec.value )
				cb.build_memoryAccess( ctexec.value );
		}
}
