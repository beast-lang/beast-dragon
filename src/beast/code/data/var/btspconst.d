module beast.code.data.var.btspconst;

import beast.code.data.toolkit;
import beast.code.data.var.static_;

final class Symbol_BootstrapConstant : Symbol_StaticVariable {

	public:
		/// Length of the data is inferred from the dataType instance size
		this( DataEntity parent, Identifier identifier, Symbol_Type dataType, ulong data ) {
			super( parent );
			assert( dataType.instanceSize <= data.sizeof );

			dataType_ = dataType;
			identififer_ = identifier;

			with ( memoryManager.session ) {
				auto block = memoryManager.allocBlock( dataType.instanceSize );
				block.markDoNotGCAtSessionEnd();
				block.identifier = identifier.str;
				block.relatedDataEntity = dataEntity;

				assert( data.sizeof >= dataType.instanceSize );
				memoryPtr_ = block.startPtr.write( &data, dataType.instanceSize );
			}
		}

	public:
		override Identifier identifier( ) {
			return identififer_;
		}

		override Symbol_Type dataType( ) {
			return dataType_;
		}

		override MemoryPtr memoryPtr( ) {
			return memoryPtr_;
		}

		override bool isCtime( ) {
			return true;
		}

	protected:
		Symbol_Type dataType_;
		Identifier identififer_;
		MemoryPtr memoryPtr_;

}
