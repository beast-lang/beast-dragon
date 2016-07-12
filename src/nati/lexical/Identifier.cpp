#include "Identifier.h"

namespace nati {

	using IdentifierTableItem = std::unique_ptr< String >;

	Identifier::Identifier() {
		ptr_ = nullptr;
	}

	Identifier::Identifier( const String &str ) {
		ptr_ = identifierTable->obtain( str );
	}

	Identifier::Identifier( const Identifier &other ) {
		ptr_ = other.ptr_;
	}

	const String &Identifier::str() const {
		return ptr_->str;
	}

	Keyword Identifier::keyword() const {
		return ptr_->keyword;
	}

	bool Identifier::operator==( const Identifier &other ) const {
		return ptr_ == other.ptr_;
	}

}
