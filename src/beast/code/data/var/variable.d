module beast.code.data.var.variable;

import beast.code.data.toolkit;

abstract class Symbol_Variable : Symbol {

	public:
		/// Variable data type
		abstract Symbol_Type dataType( );

		MemoryPtr memoryPtr( ) {
			return memoryPtr_;
		}

	protected:
		/// Pointer that holds (initial value for runtime variables) data of the variable
		MemoryPtr memoryPtr_;

}
