module beast.testsuite.directive.run;

import beast.testsuite.directive.directive;
import std.json;

final class TestDirective_Run : TestDirective {

	public:
		this( TestDirectiveArguments args ) {
			
		}

	public:
		override void onBeforeTestStart( ) {
			test.needsCompilation = true;
			test.runAfterBuild = true;
		}

}
