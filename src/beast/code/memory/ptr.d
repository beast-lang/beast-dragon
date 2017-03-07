module beast.code.memory.ptr;

import beast.code.toolkit;
import beast.code.memory.block;
import beast.code.memory.memorymgr;
import beast.code.data.type.type;

enum nullMemoryPtr = MemoryPtr( 0 );

/// Pointer to Beast interpret memory (target machine memory)
struct MemoryPtr {

	public:
		size_t val;

	public:
		/// Returns memory block corresponding to this pointer
		MemoryBlock block( ) {
			return memoryManager.findMemoryBlock( this );
		}

	public:
		/// Writes a "primitive" (direct data copy - usually you should use hwenv) into given pointer
		MemoryPtr writePrimitive( T )( const auto ref T data ) const {
			memoryManager.write( this, cast( const void* )&data, data.sizeof );
			return this;
		}

		MemoryPtr write( const void* data, size_t bytes ) const {
			memoryManager.write( this, data, bytes );
			return this;
		}

		MemoryPtr write( MemoryPtr data, size_t bytes ) const {
			memoryManager.write( this, memoryManager.read( data, bytes ), bytes );
			return this;
		}

		/// Reads a "primitive" (direct data read - usually you should use hwenv) from a given pointer
		T readPrimitive( T )( ) const {
			return *( cast( T* ) memoryManager.read( this, T.sizeof ) );
		}

	public:
		/// Interprets the value as a Type variable
		Symbol_Type readType( ) const {
			Symbol_Type type = typeUIDKeeper[ readPrimitive!size_t ];
			benforce( type !is null, E.invalidPointer, "Variable does not point to a valid type" );
			return type;
		}

	public:
		bool dataEquals( MemoryPtr other, size_t comparedLength ) const {
			import core.stdc.string : memcmp;

			void* data1 = memoryManager.read( this, comparedLength );
			void* data2 = memoryManager.read( this, comparedLength );
			return memcmp( data1, data2, comparedLength ) == 0;
		}

	public:
		int opCmp( MemoryPtr other ) const {
			if ( val > other.val )
				return 1;
			else if ( val < other.val )
				return -1;
			else
				return 0;
		}

		bool isNull( ) const {
			return val == 0;
		}

	public:
		MemoryPtr opBinary( string op )( MemoryPtr other ) if ( op == "+" || op == "-" ) {
			return mixin( "MemoryPtr( val " ~ op ~ " other.val )" );
		}

		MemoryPtr opBinary( string op )( size_t other ) if ( op == "+" || op == "-" ) {
			return mixin( "MemoryPtr( val " ~ op ~ " other )" );
		}

	public:
		string toString( ) const {
			return "0x%x".format( val );
		}

		bool opCast( T : bool )( ) const {
			return val != 0;
		}

}
