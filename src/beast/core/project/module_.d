module beast.core.project.module_;

import beast.toolkit;
import beast.util.identifiable;
import beast.core.project.codesource;
import beast.core.task.guard;
import beast.code.ast.decl.module_;
import beast.code.lex.identifier;
import beast.code.semantic.module_.user;
import beast.code.lex.token;
import beast.code.lex.lexer;
import beast.core.project.configuration;
import beast.core.project.codelocation;

/// Abstraction of module in Beast (as a project file)
/// See also Symbol_Module and Symbol_UserModule in beast.code.semantic.module_.XX
final class Module : CodeSource, Identifiable {
	mixin TaskGuard!("parsing");

public:
	this(CTOR_FromFile _, string filename, ExtendedIdentifier identifier) {
		this.identifier = identifier;

		super(_, filename);
	}

public:
	ExtendedIdentifier identifier;

	AST_Module ast() {
		enforceDone_parsing();
		return astWIP_;
	}

	/// Symbol of the module
	Symbol_UserModule symbol() {
		enforceDone_parsing();
		return symbolWIP_;
	}

	Token[] tokenList() {
		// TODO: Don't always keep tokenlist
		enforceDone_parsing();
		return tokenListWIP_;
	}

public:
	override string identificationString() {
		return identifier.str;
	}

private:
	void execute_parsing() {
		assert(!context.lexer);

		Lexer lexer = new Lexer(this);
		context.lexer = lexer;
		scope (exit)
			context.lexer = null;

		// If we are instructed to do only lexing phase, do it
		if (project.configuration.stopOnPhase == ProjectConfiguration.StopOnPhase.lexing) {
			while (lexer.getNextToken != Token.Special.eof) {
			}

			tokenListWIP_ = lexer.generatedTokens;
			return;
		}

		// Read first token
		lexer.getNextToken();

		astWIP_ = AST_Module.parse();
		benforce(astWIP_.identifier == identifier, E.moduleNameMismatch, "Module '" ~ astWIP_.identifier.str ~ "' should be named '" ~ identifier.str ~ "'", CodeLocation(this).errGuardFunction);

		tokenListWIP_ = lexer.generatedTokens;

		if (project.configuration.stopOnPhase == ProjectConfiguration.StopOnPhase.parsing)
			return;

		symbolWIP_ = new Symbol_UserModule(this, astWIP_);
	}

private:
	AST_Module astWIP_;
	Symbol_UserModule symbolWIP_;
	Token[] tokenListWIP_;

}

bool isValidModuleOrPackageIdentifier(string str) {
	import std.regex : ctRegex, matchFirst;

	return cast(bool) str.matchFirst(ctRegex!"^[a-z_][a-z0-9_]*$");
}
