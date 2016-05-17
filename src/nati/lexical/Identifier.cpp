
#include "Identifier.h"

namespace nati {

	using IdentifierTableItem = std::unique_ptr< std::string >;

	Identifier::Identifier( const std::string &str ) {
		ptr_ = identifierTable->obtain( str );
	}

	Identifier::Identifier( const Identifier &other ) {
		ptr_ = other.ptr_;
	}

	const std::string &Identifier::str() const {
		return ptr_->str;
	}

	bool Identifier::operator==( const Identifier &other ) const {
		return ptr_ == other.ptr_;
	}

	size_t Identifier::hash() const {
		return ptr_->hash;
	}

}
