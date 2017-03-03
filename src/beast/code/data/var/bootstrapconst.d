module beast.code.data.var.boostrapconst;

import beast.code.data.toolkit;
import beast.code.data.var.static_;

final class Symbol_BoostrapConstant : Symbol_StaticVariable {

	public:
		/// Length of the data is inferred from the dataType instance size
		this( DataEntity parent, Identifier identifier, Symbol_Type dataType, const void* data ) {
			super( parent );

			dataType_ = dataType;
			identififer_ = identifier;

			with ( memoryManager.session )
				memoryPtr_ = memoryManager.alloc( dataType.instanceSize, MemoryBlock.Flags.doNotGCAtSessionEnd ).write( data, dataType.instanceSize );
		}

	public:
		override Identifier identifier( ) {
			return identififer_;
		}

		override Symbol_Type dataType( ) {
			return dataType_;
		}

		override bool isCtime( ) {
			return true;
		}

		override MemoryPtr memoryPtr( ) {
			return memoryPtr_;
		}

	private:
		Symbol_Type dataType_;
		MemoryPtr memoryPtr_;
		Identifier identififer_;

}
