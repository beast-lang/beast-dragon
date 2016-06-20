#ifndef NATI_IDENTIFIERTABLE_H
#define NATI_IDENTIFIERTABLE_H

#include <string>
#include <memory>
#include <unordered_map>
#include <mutex>
#include "Keyword.h"

namespace nati {

	class IdentifierTableRecord final {

	public:
		IdentifierTableRecord( const std::string &str, Keyword keyword = Keyword::notAKeyword );

	public:
		std::string str;
		/// Stores if the identifier is a keyword; Keyword::notAKeyword if not a keyword
		Keyword keyword;

	};

	/**
	 * A singleton class containing all identifiers that occured in the project.
	 * Every identifier is registred only once -> you can compare identifiers with IdentifierTableRecord pointer only (no string comparison needed)
	 */
	class IdentifierTable final {

	public:
		IdentifierTable();

	public:
		/**
		 * Creates/returns an identifier record matching the identifier :str.
		 * This function is thread safe.
		 * */
		const IdentifierTableRecord* obtain( const std::string &str );
		/**
		 * Registers an identifier as a keyword.
		 *
		 * @remark This function is not thread safe and should be run only before worker threads start.
		 */
		void registerKeyword( const std::string &str, Keyword keyword );

	private:
		/// This function is only called in the constructor
		void registerKeywords();

	private:
		std::unordered_map< std::string, std::unique_ptr< const IdentifierTableRecord > > table_;
		std::mutex mutex_;

	};

	extern IdentifierTable *identifierTable;

}

#endif //NATI_IDENTIFIERTABLE_H
