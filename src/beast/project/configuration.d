module beast.project.configuration;

import beast.project.codesource;
import beast.toolkit;
import beast.utility.decorator;
import beast.utility.enumassoc;
import std.array;
import std.file;
import std.json;
import std.conv;
import std.path;
import std.algorithm;
import std.stdio;
import std.traits;

/// Project configuration storage class
struct ProjectConfiguration {

public:
	enum MessageFormat {
		standard,
		json
	}

public:
	@configurable {
		/// File name of target application/library
		string targetFilename;

		/// Array of source file root directories
		string[ ] sourceDirectories;

		/// Output message format
		MessageFormat messageFormat;
	}

public:
	/// Loads configuration from specified project file
	void loadFromFile( string filename ) {
		CodeSource source = new CodeSource( filename );

		JSONValue json;
		try {
			json = source.content.parseJSON;
		}
		catch ( JSONException exc ) {
			berror( CodeLocation( source ), BError.invalidProjectFile, "Project file JSON parsing error: " ~ exc.msg );
		}

		loadFromJSON( json, source );
	}

	/// Loads cofnguration from specified JSON data
	void loadFromJSON( JSONValue data, CodeSource source ) {
		benforce( data.type == JSON_TYPE.OBJECT, CodeLocation( source ), BError.invalidProjectFile, "Project configuration: file root is not an object" );

		auto root = data.object;

		itemIteration: foreach ( rootItem; root.byKeyValue ) {
			const string key = rootItem.key;
			const JSONValue val = rootItem.value;

			foreach ( i, memberName; __traits( derivedMembers, ProjectConfiguration ) ) {
				static if ( hasUDA!( __traits( getMember, ProjectConfiguration, memberName ), configurable ) ) {
					if ( key != memberName )
						continue;

					processItem!( typeof( __traits( getMember, ProjectConfiguration, memberName ) ), memberName )( key, val, source );

					continue itemIteration;
				}
			}

			berror( CodeLocation( source ), BError.invalidProjectFile, "Unknown key '" ~ key ~ "'" );
		}
	}

private:
	void processItem( T : string, string memberName )( string key, JSONValue val, CodeSource source ) {
		benforce( val.type == JSON_TYPE.STRING, CodeLocation( source ), BError.invalidProjectFile, "Project configuration: expected string for key '" ~ key ~ "'" );

		__traits( getMember, this, memberName ) = val.str;
	}

	void processItem( T : bool, string memberName )( string key, JSONValue val ) {
		benforce( val.type in [ JSON_TYPE.TRUE, JSON_TYPE.FALSE ], CodeLocation( source ), BError.invalidProjectFile, "Project configuration: expected boolean for key '" ~ key ~ "'" );

		__traits( getMember, this, memberName ) = ( val.type == JSON_TYPE.TRUE );
	}

	void processItem( T : string[ ], string memberName )( string key, JSONValue val, CodeSource source ) {
		benforce( val.type == JSON_TYPE.ARRAY, CodeLocation( source ), BError.invalidProjectFile, "Project configuration: expected array for key '" ~ key ~ "'" );

		foreach ( i, item; val.array ) {
			benforce( item.type == JSON_TYPE.STRING, CodeLocation( source ), BError.invalidProjectFile, "Project configuration: expected string for key '%s[%s]'".format( key, i ) );
			__traits( getMember, this, memberName ) ~= item.str;
		}
	}

	void processItem( T, string memberName )( string key, JSONValue val, CodeSource source ) if ( is( T == enum ) ) {
		alias assoc = enumAssoc!T;

		benforce( val.type == JSON_TYPE.STRING, CodeLocation( source ), BError.invalidProjectFile, "Project configuration: expected string for key '" ~ key ~ "'" );
		benforce( ( val.str in assoc ) !is null, CodeLocation( source ), BError.invalidProjectFile, "Project configuration: key '" ~ key ~ "' can only contain values: " ~ assoc.byKey.map!( x => "'" ~ x ~ "'" ).joiner( ", " ).array.to!string );

		__traits( getMember, this, memberName ) = assoc[ val.str ];
	}

private:
	alias configurable = Decorator!"ProjectConfiguration.configurable";

}
