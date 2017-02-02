module beast.core.project.configuration;

import beast.core.project.codesource;
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
import std.meta;

/// Project configuration storage class
struct ProjectConfiguration {

public:
	// Can't put UDAs on enum members, sucks ( https://github.com/dlang/dmd/pull/6161 )
	// TODO: Put help UDAs when they finally add them
	enum MessageFormat {
		gnu, /// Standard GNU error messages
		json // Wrapped in JSON object, contain more data
	}

public:
	@configurable {
		/// File name of target application/library
		@help( "File name of the target application/library" )
		string targetFilename;

		/// Array of source file root directories; in project.finishConfiguration, they're translated to absolute paths.
		@help( "Root source file directories; all modules in these directories are included in the project" )
		string[ ] sourceDirectories;

		/// Root include directories; modules in include directories are not included in the project unless they're explicitly imported; in project.finishConfiguration, they're translated to absolute paths.
		@help( "Root include directories; modules in these directories are not included in the project unless they're explicitly imported" )
		string[ ] includeDirectories;

		/// Source files included in the project
		@help( "Explicit source files included in the project" )
		string[ ] sourceFiles;

		/// Output message format
		@help( "Format of compiler messages" )
		MessageFormat messageFormat = MessageFormat.gnu;

		@help( "If set to true, target application will be run after succesful build" )
		bool runAfterBuild;
	}

public:
	/// Loads cofnguration from specified configuration builder
	void load( JSONValue[ string ] data ) {
		itemIteration: foreach ( item; data.byKeyValue ) {
			const string key = item.key;
			const JSONValue val = item.value;

			foreach ( i, memberName; __traits( derivedMembers, ProjectConfiguration ) ) {
				alias member = Alias!( __traits( getMember, ProjectConfiguration, memberName ) );

				static if ( hasUDA!( member, configurable ) ) {
					if ( key != memberName )
						continue;

					loadItem!( typeof( member ), memberName )( key, val );

					continue itemIteration;
				}
			}

			/// Unknown keys should be handled by the builder
			assert( 0 );
		}
	}

	/// Prints help to stdout
	void printHelp( ) {
		writeln( "Configuration options:" );

		foreach ( i, memberName; __traits( derivedMembers, ProjectConfiguration ) ) {
			alias member = Alias!( __traits( getMember, ProjectConfiguration, memberName ) );

			static if ( hasUDA!( member, configurable ) ) {
				alias Member = typeof( member );

				writef( "  %s = %s\n    %s\n\n", memberName, help_possibleValues!( Member ), getUDAs!( member, help )[ 0 ].data[ 0 ] );

				// TODO: uncomment after UDAs on enum members are allowed
				/*static if ( is( Member == enum ) ) {
					foreach ( i, valueName; __traits( derivedMembers, Member ) ) {
						alias value = Alias!( __traits( getMember, Member, valueName ) );

						writef( "    %s: %s\n", valueName, getUDAs!( value, help )[ 0 ].data[ 0 ] );
					}
					writeln;
				}*/
			}
		}
	}

private:
	void loadItem( T : string, string memberName )( string key, JSONValue val ) {
		benforce( val.type == JSON_TYPE.STRING, E.invalidProjectConfiguration, "Project configuration: expected string for key '" ~ key ~ "'" );

		__traits( getMember, this, memberName ) = val.str;
	}

	void loadItem( T : bool, string memberName )( string key, JSONValue val ) {
		benforce( val.type == JSON_TYPE.TRUE || val.type == JSON_TYPE.FALSE, E.invalidProjectConfiguration, "Project configuration: expected boolean for key '" ~ key ~ "'" );

		__traits( getMember, this, memberName ) = ( val.type == JSON_TYPE.TRUE );
	}

	void loadItem( T : string[ ], string memberName )( string key, JSONValue val ) {
		benforce( val.type == JSON_TYPE.ARRAY, E.invalidProjectConfiguration, "Project configuration: expected array for key '" ~ key ~ "'" );

		foreach ( i, item; val.array ) {
			benforce( item.type == JSON_TYPE.STRING, E.invalidProjectConfiguration, "Project configuration: expected string for key '%s[%s]'".format( key, i ) );
			__traits( getMember, this, memberName ) ~= item.str;
		}
	}

	void loadItem( T, string memberName )( string key, JSONValue val ) if ( is( T == enum ) ) {
		alias assoc = enumAssoc!T;

		benforce( val.type == JSON_TYPE.STRING, E.invalidProjectConfiguration, "Project configuration: expected string for key '" ~ key ~ "'" );
		benforce( ( val.str in assoc ) !is null, E.invalidProjectConfiguration, "Project configuration: key '" ~ key ~ "' can only contain values " ~ assoc.byKey.map!( x => "'" ~ x ~ "'" ).joiner( ", " ).array.to!string );

		__traits( getMember, this, memberName ) = assoc[ val.str ];
	}

private:
	string help_possibleValues( T : string )( ) {
		return "string";
	}

	string help_possibleValues( T : bool )( ) {
		return "true/false";
	}

	string help_possibleValues( T : string[ ] )( ) {
		return "array of strings";
	}

	string help_possibleValues( T )( ) if ( is( T == enum ) ) {
		return enumAssoc!T.byKey.map!( x => '"' ~ x ~ '"' ).joiner( ", " ).array.to!string;
	}

private:
	alias help = Decorator!( "ProjectConfiguration.help", string );
	alias configurable = Decorator!"ProjectConfiguration.configurable";

}

/// ProjectConfigurationBuilder is used for building project configuration from parts, handles overriding config values, project configurations & merging JSON arrays and objects
final class ProjectConfigurationBuilder {

public:
	void applyFile( string filename ) {
		CodeSource source = new CodeSource( CodeSource.CTOR_FromFile( ), filename );
		const auto _gd = ErrorGuard( CodeLocation( source ) );

		JSONValue json;
		try {
			json = source.content.parseJSON;
		}
		catch ( JSONException exc ) {
			// TODO: parse line and column from this
			berror( E.invalidProjectConfiguration, "Project file JSON parsing error: " ~ exc.msg );
		}

		applyJSON( json );
	}

	void applyJSON( JSONValue json ) {
		benforce( json.type == JSON_TYPE.OBJECT, E.invalidProjectConfiguration, "Project configuration: json root is not an object" );

		itemIteration: foreach ( item; json.object.byKeyValue ) {
			const string fullKey = item.key;
			const JSONValue val = item.value;

			// Split the key by first '@'; the left part is the key itself and the right part is the key group
			const string keyBase = fullKey.findSplit( "@" )[ 0 ];

			foreach ( i, memberName; __traits( derivedMembers, ProjectConfiguration ) ) {
				static if ( hasUDA!( __traits( getMember, ProjectConfiguration, memberName ), ProjectConfiguration.configurable ) ) {
					if ( keyBase != memberName )
						continue;

					data_[ fullKey ] = val;
					continue itemIteration;
				}
			}

			berror( E.invalidProjectConfiguration, "Project configuration: unknown key '" ~ keyBase ~ "'" );
		}
	}

public:
	JSONValue[ string ] build( ) {
		JSONValue[ string ] result;

		foreach ( it; data_.byKeyValue ) {
			const string fullKey = it.key;
			JSONValue value = it.value;

			// Split the key by first '@'; the left part is the key itself and the right part is the key group
			const auto keyBase = fullKey.findSplit( "@" )[ 0 ];

			auto existingRecord = keyBase in result;
			if ( !existingRecord ) {
				result[ keyBase ] = value;
				continue;
			}

			// Merge two objects
			if ( existingRecord.type == JSON_TYPE.OBJECT && value.type == JSON_TYPE.OBJECT ) {
				JSONValue[ string ] obj = existingRecord.object;

				// Merge objects
				foreach ( it2; value.object.byKeyValue )
					obj[ it2.key ] = it2.value;

				*existingRecord = obj;
				continue;
			}

			// Merge two arrays
			if ( existingRecord.type == JSON_TYPE.ARRAY && value.type == JSON_TYPE.ARRAY ) {
				existingRecord.array = existingRecord.array ~ value.array;
				continue;
			}

			berror( E.invalidProjectConfiguration, "Cannot merge key '%s' into configuration, unsupported value type combination: %s and %s".format( fullKey, existingRecord.type.to!string, value.type.to!string ) );
		}

		return data_;
	}

private:
	JSONValue[ string ] data_;

}
