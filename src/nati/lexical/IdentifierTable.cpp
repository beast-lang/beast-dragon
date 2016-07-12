#include "IdentifierTable.h"

namespace nati {

	IdentifierTable *identifierTable = nullptr;

	IdentifierTableRecord::IdentifierTableRecord( const String &str, Keyword keyword ) {
		this->str = str;
		this->keyword = keyword;
	}

	IdentifierTable::IdentifierTable() {
		registerKeywords();
	}

	const IdentifierTableRecord *IdentifierTable::obtain( const String &str ) {
		mutex_.lock();

		UniquePtr< const IdentifierTableRecord > &record = table_[ str ];
		if( !record )
			record.reset( new IdentifierTableRecord( str ) );

		mutex_.unlock();

		return record.get();
	}

	void IdentifierTable::registerKeyword( const String &str, Keyword keyword ) {
		table_[ str ].reset( new IdentifierTableRecord( str, keyword ) );
	}

	void IdentifierTable::registerKeywords() {
		registerKeyword( "this", Keyword::this_ );
	}

}
