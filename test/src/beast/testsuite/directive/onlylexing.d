module beast.testsuite.directive.onlylexing;

import beast.testsuite.directive.directive;

final class TestDirective_OnlyLexing : TestDirective {

public:
	this( TestDirectiveArguments args ) {
	}

public:
	override void onBeforeTestStart( ) {
		test.args ~= [ "--config", "stopOnPhase=lexing" ];
	}

}
