module beast.code.data.var.contextptr;

import beast.code.data.toolkit;
import beast.code.data.var.local;

final class DataEntity_ContextPointer : DataEntity_LocalVariable {

	public:
		this( Identifier identifier, Symbol_Type parentType, MemoryPtr ctimeValue = MemoryPtr( 0 ) ) {
			super( parentType, !ctimeValue.isNull, MemoryBlock.Flag.contextPtr );

			if( !ctimeValue.isNull )
				memoryPtr.write( ctimeValue, parentType.instanceSize );

			identifier_ = identifier;
			interpreterBpOffset = -1; // Context pointer is always bp offset -1 (even if there is no context needed)
		}

	public:
		override Identifier identifier( ) {
			return identifier_;
		}

		override AST_Node ast( ) {
			return null;
		}

	private:
		Identifier identifier_;

}
