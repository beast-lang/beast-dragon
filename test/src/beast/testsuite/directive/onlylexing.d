module beast.testsuite.directive.onlylexing;

import beast.testsuite.directive.directive;

/// Passes an argument to the compiler so only lexing phase is done
final class TestDirective_OnlyLexing : TestDirective {

public:
	this(TestDirectiveArguments args) {
	}

public:
	override void onBeforeTestStart() {
		assert(test.stopOnPhase == StopOnPhase.doEverything, "%s %s".format(test.identifier, test.stopOnPhase));
		test.stopOnPhase = StopOnPhase.lexing;
	}

}
