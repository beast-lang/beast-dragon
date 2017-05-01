module beast.util.hash;

import std.digest.murmurhash : MurmurHash3;
import std.typecons : Typedef;

struct Hash {

	public:
		alias Data = Typedef!( size_t );

	public:
		this( string str ) {
			MurmurHash3!( 32 ) hash;
			hash.put( cast( const( ubyte )[ ] ) str );
			hash.finalize( );
			data = hash.get;
		}

		this( const( ubyte )[ ] data ) {
			MurmurHash3!( Data.sizeof * 8 ) hash;
			hash.put( data );
			hash.finalize( );
			this.data = hash.get;
		}

		this( size_t data ) {
			this.data = 0x9e3779b9 + ( cast( size_t ) data << 6 ) + ( cast( size_t ) data >> 2 );
		}

		this( Data data ) {
			this.data = data;
		}

	public:
		Data data;

	public:
		/// Encodes hash into a valid identifier (a-zA-F)
		string str( ) {
			enum chars = "0123456789abcdefghijklmopqrstvuw";

			size_t val = cast( size_t ) data;
			string result;

			while ( val ) {
				result ~= chars[ val % chars.length ];
				val /= chars.length;
			}

			return result;
		}

	public:
		/// Combines two hashes
		Hash opBinary( string op : "+" )( Hash other ) {
			// Got this from boost
			return Hash( data + 0x9e3779b9 + ( other.data << 6 ) + ( other.data >> 2 ) );
		}

	public:
		void opOpAssign( string op : "+" )( Hash other ) {
			this = opBinary!op( other );
		}

}
