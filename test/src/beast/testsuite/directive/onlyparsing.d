module beast.testsuite.directive.onlyparsing;

import beast.testsuite.directive.directive;

/// Passes an argument to the compiler so only lexing phase is done
final class TestDirective_OnlyParsing : TestDirective {

	public:
		this( TestDirectiveArguments args ) {
		}

	public:
		override void onBeforeTestStart( ) {
			test.args ~= [ "--config", "stopOnPhase=parsing" ];
		}

}
