module beast.core.project.configuration;

import beast.toolkit;
import std.json;
import beast.util.decorator;
import beast.util.enumassoc;
import beast.core.project.codesource;
import beast.core.error.guard;
import beast.core.project.codelocation;
import std.parallelism : totalCPUs;
import std.typecons : Typedef;

/// Project configuration storage class
struct ProjectConfiguration {

public:
	// TODO: Actually do something with the help UDA in the enum
	enum MessageFormat {
		@help("Standard GNU error messages")
		gnu,
		@help("JSON-formatted error messages, contain more data")
		json
	}
	/// Compiler can be configured to stop at certaing compilation phase
	enum StopOnPhase {
		@help("Do only lexical analysis")
		lexing,
		@help("Do lexical and syntax analysis")
		parsing,
		codegen,
		outputgen,
		doEverything,
	}

	alias IntGt0 = Typedef!(int, 1, "IntGt0");

public:
	@configurable {
		@help("File name of the target application/library.")
		string targetFilename;

		@help("Root source file directories\nAll modules in these directories are included in the project.")
		string[] sourceDirectories;

		@help("Root include directories\nModules in these directories are not included in the project unless they're explicitly imported.")
		string[] includeDirectories;

		@help("Explicit source files included in the project.")
		string[] sourceFiles;

		@help("Directory where the output files are generated to")
		string outputDirectory = ".";

		@help("Format of compiler messages")
		MessageFormat messageFormat = MessageFormat.gnu;

		@help("If set to true, target application will be run after succesful build.")
		bool runAfterBuild;

		@help("The compiler can be configured to stop at certain compilation phase.")
		StopOnPhase stopOnPhase = StopOnPhase.doEverything;

		@help("How many thread workers will spawn (implicit = number of cores)")
		IntGt0 workerCount; // = totalCPUs; in initialize

		@help("Module that contains the Void main() function")
		string entryModule;

		@help("Maximum function call recursion in the interpreter")
		IntGt0 maxRecursion = 1024;
	}

public:
	version (cppBackend) @configurable {
		@help("When true, instead of creating a .cpp file, the code is written to stdout")
		bool outputCodeToStdout;

		@help("Program used to compile the C++ code")
		string cppCompiler = "g++";

		@help("Command that is executed for compiling the C++ code (you can use %COMPILER%, %SOURCE% and %TARGET%)")
		string compileCommand = "%COMPILER% %SOURCE% -o %TARGET%";
	}

public:
	debug @configurable {
		@help("Show stack trace on error report")
		bool showStackTrace;
	}

public:
	void initialize() {
		workerCount = totalCPUs;
	}

	/// Loads cofnguration from specified configuration builder
	void load(JSONValue[string] data) {
		itemIteration: foreach (key, val; data) {
			foreach (i, memberName; __traits(derivedMembers, ProjectConfiguration)) {
				foreach (uda; __traits(getAttributes, __traits(getMember, ProjectConfiguration, memberName))) {
					static if (is(uda == configurable)) {
						if (key != memberName)
							continue;

						loadItem!(typeof(__traits(getMember, ProjectConfiguration, memberName)), memberName)(key, val);

						continue itemIteration;
					}
				}
			}

			/// Unknown keys should be handled by the builder
			assert(0, "Unknown key " ~ key);
		}
	}

	/// Prints help to stdout
	void printHelp() {
		import std.stdio : writeln, writef;
		import std.array : replace;

		writeln("Configuration options:");

		memberIteration: foreach (i, memberName; __traits(derivedMembers, ProjectConfiguration)) {
			foreach (uda; __traits(getAttributes, __traits(getMember, ProjectConfiguration, memberName))) {
				static if (is(typeof(uda) == help)) {
					alias Member = typeof(__traits(getMember, ProjectConfiguration, memberName));

					writef("  %s = %s\n    %s\n\n", memberName, help_possibleValues!(Member), uda.data[0].replace("\n", "\n    "));

					// TODO: uncomment after UDAs on enum members are allowed
					/*static if ( is( Member == enum ) ) {
						foreach ( i, valueName; __traits( derivedMembers, Member ) ) {
							alias value = Alias!( __traits( getMember, Member, valueName ) );

							writef( "    %s: %s\n", valueName, getUDAs!( value, help )[ 0 ].data[ 0 ] );
						}
						writeln;
					}*/
					continue memberIteration;
				}
			}
		}
	}

public:
	/// Processes smart opt (used in --config key=value for comiler opts)
	static JSONValue processSmartOpt(string key, string value) {
		foreach (i, memberName; __traits(derivedMembers, ProjectConfiguration)) {
			foreach (uda; __traits(getAttributes, __traits(getMember, ProjectConfiguration, memberName))) {
				static if (is(uda == configurable)) {
					if (key == memberName)
						return smartOpt!(typeof(__traits(getMember, ProjectConfiguration, memberName)))(key, value);
				}
			}
		}

		berror(E.invalidOpts, "Opt key '" ~ key ~ "' is invalid.");
		assert(0);
	}

private:
	static JSONValue smartOpt(T : string)(string key, string value) {
		return value.JSONValue;
	}

	static JSONValue smartOpt(T : bool)(string key, string value) {
		import std.uni : toLower;

		switch (value.toLower) {

		case "true", "1", "yes", "on", "":
			return true.JSONValue;

		case "false", "0", "no", "off":
			return false.JSONValue;

		default:
			berror(E.invalidOpts, "Invalid value '" ~ value ~ "' for key '" ~ key ~ "' of type BOOLEAN");
			assert(0);

		}
	}

	static JSONValue smartOpt(T : string[])(string key, string value) {
		import std.algorithm.iteration : splitter;
		import std.string : strip;

		// Array is splitted by ","
		return value.splitter(",").map!(x => x.strip.JSONValue).array.JSONValue;
	}

	static JSONValue smartOpt(T)(string key, string value) if (is(T == enum)) {
		alias assoc = enumAssoc!T;
		benforce((value in assoc) !is null, E.invalidOpts, "Key '" ~ key ~ "' (='" ~ value ~ "') can only contain values " ~ assoc.byKey.map!(x => "'" ~ x ~ "'").joiner(", ").to!string);

		return value.JSONValue;
	}

	static JSONValue smartOpt(T : IntGt0)(string key, string value) {
		import std.format : formattedRead;

		int val;
		int result;

		try {
			result = value.formattedRead("%s", &val);
		}
		catch (Throwable t) {
			berror(E.invalidOpts, "Could not parse key %s (='%s') into a number".format(key, value));
		}

		benforce(result == 1, E.invalidOpts, "Key '%s' (='%s') is not a number".format(key, value));
		return JSONValue(val);
	}

private:
	void loadItem(T : string, string memberName)(string key, JSONValue val) {
		benforce(val.type == JSON_TYPE.STRING, E.invalidProjectConfiguration, "Project configuration: expected string for key '" ~ key ~ "'");

		__traits(getMember, this, memberName) = val.str;
	}

	void loadItem(T : bool, string memberName)(string key, JSONValue val) {
		benforce(val.type == JSON_TYPE.TRUE || val.type == JSON_TYPE.FALSE, E.invalidProjectConfiguration, "Project configuration: expected boolean for key '" ~ key ~ "'");

		__traits(getMember, this, memberName) = (val.type == JSON_TYPE.TRUE);
	}

	void loadItem(T : string[], string memberName)(string key, JSONValue val) {
		benforce(val.type == JSON_TYPE.ARRAY, E.invalidProjectConfiguration, "Project configuration: expected array for key '" ~ key ~ "'");

		foreach (i, item; val.array) {
			benforce(item.type == JSON_TYPE.STRING, E.invalidProjectConfiguration, "Project configuration: expected string for key '%s[%s]'".format(key, i));
			__traits(getMember, this, memberName) ~= item.str;
		}
	}

	void loadItem(T, string memberName)(string key, JSONValue val) if (is(T == enum)) {
		alias assoc = enumAssoc!T;

		benforce(val.type == JSON_TYPE.STRING, E.invalidProjectConfiguration, "Project configuration: expected string for key '" ~ key ~ "'");
		benforce((val.str in assoc) !is null, E.invalidProjectConfiguration, "Project configuration: key '" ~ key ~ "' (='" ~ val.str ~ "') can only contain values " ~ assoc.byKey.map!(x => "'" ~ x ~ "'").joiner(", ").to!string);

		__traits(getMember, this, memberName) = assoc[val.str];
	}

	void loadItem(T : IntGt0, string memberName)(string key, JSONValue val) {
		benforce(val.type == JSON_TYPE.INTEGER, E.invalidProjectConfiguration, "Project configuration: expected number for key '" ~ key ~ "'");
		benforce(val.integer >= 1, E.invalidProjectConfiguration, "Project configuration: key '%s' must be greater than 0".format(key));

		__traits(getMember, this, memberName) = cast(int) val.integer;
	}

private:
	string help_possibleValues(T : string)() {
		return "string";
	}

	string help_possibleValues(T : bool)() {
		return "true, false";
	}

	string help_possibleValues(T : string[])() {
		return "array of strings";
	}

	string help_possibleValues(T : IntGt0)() {
		return "number > 0";
	}

	string help_possibleValues(T)() if (is(T == enum)) {
		return [__traits(derivedMembers, T)].map!(x => '"' ~ x ~ '"').joiner(", ").array.to!string;
	}

private:
	alias help = Decorator!("ProjectConfiguration.help", string);
	alias configurable = Decorator!"ProjectConfiguration.configurable";

}

/// ProjectConfigurationBuilder is used for building project configuration from parts, handles overriding config values, project configurations & merging JSON arrays and objects
final class ProjectConfigurationBuilder {

public:
	void applyFile(string filename) {
		CodeSource source = new CodeSource(CodeSource.CTOR_FromFile(), filename);
		const auto _gd = ErrorGuard(CodeLocation(source));

		JSONValue json;
		try {
			json = source.content.parseJSON;
		}
		catch (JSONException exc) {
			// TODO: parse line and column from this
			berror(E.invalidProjectConfiguration, "Project file JSON parsing error: " ~ exc.msg);
		}

		applyJSON(json);
	}

	void applyJSON(JSONValue json) {
		import std.algorithm.searching : findSplit;

		benforce(json.type == JSON_TYPE.OBJECT, E.invalidProjectConfiguration, "Project configuration: json root is not an object");

		itemIteration: foreach (fullKey, val; json.object) {
			// Split the key by first '@'; the left part is the key itself and the right part is the key group
			const string keyBase = fullKey.findSplit("@")[0];

			foreach (i, memberName; __traits(derivedMembers, ProjectConfiguration)) {
				foreach (uda; __traits(getAttributes, __traits(getMember, ProjectConfiguration, memberName))) {
					static if (is(uda == ProjectConfiguration.configurable)) {
						if (keyBase == memberName) {
							data_[fullKey] = val;
							continue itemIteration;
						}
					}
				}
			}

			berror(E.invalidProjectConfiguration, "Project configuration: unknown key '" ~ keyBase ~ "'");
		}
	}

public:
	JSONValue[string] build() {
		import std.algorithm.searching : findSplit;

		JSONValue[string] result;

		foreach (fullKey, value; data_) {
			// Split the key by first '@'; the left part is the key itself and the right part is the key group
			const auto keyBase = fullKey.findSplit("@")[0];

			auto existingRecord = keyBase in result;
			if (!existingRecord) {
				result[keyBase] = value;
				continue;
			}

			// Merge two objects
			if (existingRecord.type == JSON_TYPE.OBJECT && value.type == JSON_TYPE.OBJECT) {
				JSONValue[string] obj = existingRecord.object;

				// Merge objects
				foreach (key, value; value.object)
					obj[key] = value;

				*existingRecord = obj;
				continue;
			}

			// Merge two arrays
			if (existingRecord.type == JSON_TYPE.ARRAY && value.type == JSON_TYPE.ARRAY) {
				existingRecord.array = existingRecord.array ~ value.array;
				continue;
			}

			berror(E.invalidProjectConfiguration, "Cannot merge key '%s' into configuration, unsupported value type combination: %s and %s".format(fullKey, existingRecord.type.to!string, value.type.to!string));
		}

		return result;
	}

private:
	JSONValue[string] data_;

}
