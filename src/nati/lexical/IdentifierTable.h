#ifndef NATI_IDENTIFIERTABLE_H
#define NATI_IDENTIFIERTABLE_H

#include <string>
#include <unordered_map>
#include <mutex>
#include <memory>

namespace nati {

	class IdentifierTableRecord {

	public:
		IdentifierTableRecord( const std::string &str, bool isKeyword = false );

	public:
		std::string str;
		size_t hash;
		bool isKeyword;

	};

	/**
	 * A singleton class containing all identifiers that occured in the project.
	 * Every identifier is registred only once -> you can compare identifiers with IdentifierTableRecord pointer only (no string comparison needed)
	 */
	class IdentifierTable {

	public:
		const IdentifierTableRecord* obtain( const std::string &str );

	private:
		std::unordered_map< std::string, std::unique_ptr< const IdentifierTableRecord > > table_;
		std::mutex mutex_;

	};

	extern IdentifierTable *identifierTable;

}

#endif //NATI_IDENTIFIERTABLE_H
