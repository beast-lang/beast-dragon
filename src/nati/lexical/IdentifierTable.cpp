#include "IdentifierTable.h"

namespace nati {

	IdentifierTable *identifierTable = NULL;

	IdentifierTableRecord::IdentifierTableRecord( const std::string &str, bool isKeyword /* = false */ ) {
		this->str = str;
		this->isKeyword = isKeyword;

		// Compute the hash
		{
			// Got this from http://burtleburtle.net/bob/hash/integer.html
			size_t hash = (size_t) this;
			hash = ( hash + 0x7ed55d16 ) + ( hash << 12 );
			hash = ( hash ^ 0xc761c23c ) ^ ( hash >> 19 );
			hash = ( hash + 0x165667b1 ) + ( hash << 5 );
			hash = ( hash + 0xd3a2646c ) ^ ( hash << 9 );
			hash = ( hash + 0xfd7046c5 ) + ( hash << 3 );
			hash = ( hash ^ 0xb55a4f09 ) ^ ( hash >> 16 );
			this->hash = hash;
		}
	}

	const IdentifierTableRecord *IdentifierTable::obtain( const std::string &str ) {
		mutex_.lock();

		std::unique_ptr< const IdentifierTableRecord > &record = table_[ str ];
		if( !record )
			record = std::unique_ptr< const IdentifierTableRecord >( new IdentifierTableRecord( str ) );

		mutex_.unlock();

		return record.get();
	}

}
