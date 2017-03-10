module beast.code.data.var.contextptr;

import beast.code.data.toolkit;
import beast.code.data.var.local;

final class DataEntity_ContextPointer : DataEntity_LocalVariable {

	public:
		this( DataScope scope_, Identifier identifier, Symbol_Type parentType, MemoryPtr ctimeValue = MemoryPtr( 0 ) ) {
			super( parentType, scope_, !ctimeValue.isNull, MemoryBlock.Flag.contextPtr );

			identifier_ = identifier;
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
