module beast.project.configuration;

import std.array;
import std.json;
import std.file;
import std.stdio;
import std.path;
import std.traits;

import beast.toolkit;
import beast.utility.decorator;

/// Project configuration storage class
struct ProjectConfiguration {

public:
	@configurable {
		/// File name of target application/library
		string targetFilename;

		/// Array of source file paths
		string[ ] sourcePaths;
	}

public:
	/// Loads configuration from specified project file
	void loadFromFile( string filename ) {
		const auto fileCtx = ErrorContext( [ "configFile" : filename.absolutePath ] );

		try {
			loadFromJSON( filename.readText.parseJSON );
		}
		catch ( JSONException exc ) {
			berror( "json parsing error: %s", exc.msg );
		}
		catch ( FileException exc ) {
			berror( "file error: %s", exc.msg );
		}
	}

	/// Loads cofnguration from specified JSON data
	void loadFromJSON( in JSONValue data ) {
		benforce( data.type == JSON_TYPE.OBJECT, "root is not an object" );

		auto root = data.object;

		itemIteration: foreach ( rootItem; root.byKeyValue ) {
			const string key = rootItem.key;
			const JSONValue val = rootItem.value;

			const auto itemCtx = ErrorContext( [ "configFileKey": key ] );

			foreach ( i, memberName; __traits( derivedMembers, ProjectConfiguration ) ) {
				static if ( hasUDA!( __traits( getMember, ProjectConfiguration, memberName ), configurable ) ) {
					if ( key != memberName )
						continue;

					processItem!( typeof( __traits( getMember, ProjectConfiguration, memberName ) ), memberName )( val );

					continue itemIteration;
				}
			}

			berror( "unknown key" );
		}
	}

private:
	void processItem( T : string, string memberName )( JSONValue val ) {
		benforce( val.type == JSON_TYPE.STRING, "expected string value" );

		__traits( getMember, this, memberName ) = val.str;
	}

	void processItem( T : bool, string memberName )( JSONValue val ) {
		benforce( val.type == JSON_TYPE.TRUE || val.type == JSON_TYPE.FALSE, "expected boolean value" );

		__traits( getMember, this, memberName ) = ( val.type == JSON_TYPE.TRUE );
	}

	void processItem( T : string[ ], string memberName )( JSONValue val ) {
		benforce( val.type == JSON_TYPE.ARRAY, "expected array" );

		foreach ( i, item; val.array ) {
			benforce( item.type == JSON_TYPE.STRING, "expected string item (index %s)", i );
			__traits( getMember, this, memberName ) ~= item.str;
		}
	}

private:
	alias configurable = Decorator!"ProjectConfiguration.configurable";

}
