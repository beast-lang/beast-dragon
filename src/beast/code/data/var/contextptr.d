module beast.code.data.var.contextptr;

import beast.code.data.toolkit;
import beast.code.data.function_.expandedparameter;

final class DataEntity_ContextPointer : DataEntity_LocalVariable {

	public:
		this( DataScope scope_, string identifier, Symbol_Type parentType, MemoryPtr ctimeValue = MemoryPtr( 0 ) ) {
			super( parentType, scope_, !ctimeValue.isNull, MemoryBlock.Flag.contextPtr );

			identifier_ = Identifier( identifier );
		}

	public:
		override Identifier identifier( ) {
			return identifier_;
		}

	private:
		Identifier identifier_;

}
