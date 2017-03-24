module beast.testsuite.directive.stdout;

import beast.testsuite.directive.directive;
import std.json;

/// Expects given string on stdout (mainValue argument is parsed as JSON string)
final class TestDirective_Stdout : TestDirective {

	public:
		this( TestDirectiveArguments args ) {
			data_ = args.mainValue.parseJSON.str;
		}

	public:
		override void onBeforeTestStart( ) {
			test.expectedStdout ~= data_;
			test.needsCompilation = true;
			test.runAfterBuild = true;
		}

	private:
		string data_;

}
