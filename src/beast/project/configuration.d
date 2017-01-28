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
import std.meta;

/// Project configuration storage class
struct ProjectConfiguration {

public:
	alias help = Decorator!( "ProjectConfiguration.help", string );

	// Can't put UDAs on enum members, sucks ( https://github.com/dlang/dmd/pull/6161 )
	// TODO: Put help UDAs when they finally add them
	enum MessageFormat {
		/// Standard GNU error messages
		gnu,

		// Wrapped in JSON object, contain more data
		json
	}

	enum ProjectMode {
		/// Decides based of whether sourceDirectories or originSourceFile is set
		implicit, 

		/// Standard project mode, where you have source direcotires etc
		standard,

		/// Beginning with single file, auto importing others (based of project root)
		fast
	}

public:
	@configurable {
		/// File name of target application/library
		@help( "File name of the target application/library" )
		string targetFilename;

		/// Array of source file root directories in standard project mode; in project.finishConfiguration, they're translated to absolute paths
		@help( "Root source file directories in standard project mode" )
		string[ ] sourceDirectories;

		/// Origin source file in fast project mode; in project.finishConfiguration, it is translated to absolute path
		@help( "Origin source file in fast project mode" )
		string originSourceFile;

		/// Output message format
		@help( "Format of compiler messages" )
		MessageFormat messageFormat = MessageFormat.gnu;

		/// Alters what modules are included in the project and how
		@help( "Project mode\nfast: Beginning with single file, auto including others from project root" )
		ProjectMode projectMode = ProjectMode.implicit;

		@help( "If set to true, target application will be run after succesful build." )
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
		benforce( val.type == JSON_TYPE.STRING, CodeLocation.none, BError.invalidProjectConfiguration, "Project configuration: expected string for key '" ~ key ~ "'" );

		__traits( getMember, this, memberName ) = val.str;
	}

	void loadItem( T : bool, string memberName )( string key, JSONValue val ) {
		benforce( val.type == JSON_TYPE.TRUE || val.type == JSON_TYPE.FALSE, CodeLocation.none, BError.invalidProjectConfiguration, "Project configuration: expected boolean for key '" ~ key ~ "'" );

		__traits( getMember, this, memberName ) = ( val.type == JSON_TYPE.TRUE );
	}

	void loadItem( T : string[ ], string memberName )( string key, JSONValue val ) {
		benforce( val.type == JSON_TYPE.ARRAY, CodeLocation.none, BError.invalidProjectConfiguration, "Project configuration: expected array for key '" ~ key ~ "'" );

		foreach ( i, item; val.array ) {
			benforce( item.type == JSON_TYPE.STRING, CodeLocation.none, BError.invalidProjectConfiguration, "Project configuration: expected string for key '%s[%s]'".format( key, i ) );
			__traits( getMember, this, memberName ) ~= item.str;
		}
	}

	void loadItem( T, string memberName )( string key, JSONValue val ) if ( is( T == enum ) ) {
		alias assoc = enumAssoc!T;

		benforce( val.type == JSON_TYPE.STRING, CodeLocation.none, BError.invalidProjectConfiguration, "Project configuration: expected string for key '" ~ key ~ "'" );
		benforce( ( val.str in assoc ) !is null, CodeLocation.none, BError.invalidProjectConfiguration, "Project configuration: key '" ~ key ~ "' can only contain values " ~ assoc.byKey.map!( x => "'" ~ x ~ "'" ).joiner( ", " ).array.to!string );

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
	alias configurable = Decorator!"ProjectConfiguration.configurable";

}

/// ProjectConfigurationBuilder is used for building project configuration from parts, handles overriding config values, project configurations & merging JSON arrays and objects
final class ProjectConfigurationBuilder {

public:
	void applyFile( string filename ) {
		CodeSource source = new CodeSource( CodeSource.CTOR_FromFile( ), filename );

		JSONValue json;
		try {
			json = source.content.parseJSON;
		}
		catch ( JSONException exc ) {
			// TODO: parse line and column from this
			berror( CodeLocation( source ), BError.invalidProjectConfiguration, "Project file JSON parsing error: " ~ exc.msg );
		}

		applyJSON( json, CodeLocation( source ) );
	}

	void applyJSON( JSONValue json, const CodeLocation codeLocation = CodeLocation.none ) {
		benforce( json.type == JSON_TYPE.OBJECT, codeLocation, BError.invalidProjectConfiguration, "Project configuration: json root is not an object" );

		itemIteration: foreach ( item; json.object.byKeyValue ) {
			const string key = item.key;
			const JSONValue val = item.value;

			foreach ( i, memberName; __traits( derivedMembers, ProjectConfiguration ) ) {
				static if ( hasUDA!( __traits( getMember, ProjectConfiguration, memberName ), ProjectConfiguration.configurable ) ) {
					if ( key != memberName )
						continue;

					data_[ key ] = val;
					continue itemIteration;
				}
			}

			berror( codeLocation, BError.invalidProjectConfiguration, "Project configuration: unknown key '" ~ key ~ "'" );
		}
	}

public:
	JSONValue[ string ] build( ) {
		// TODO: array and object merging
		return data_;
	}

private:
	JSONValue[ string ] data_;

}
