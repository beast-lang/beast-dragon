module beast.code.namespace.usernamespace;

import beast.code.namespace.namespace;
import beast.code.symbol.symbol;
import beast.code.ast.decl.declarationscope;
import beast.code.ast.decl.env;
import beast.core.util.identifiable;
import beast.code.symbol.symbol;
import beast.code.ast.decl.declaration;
import beast.core.task.guard;

/// User namespace - a namespace defined by the user (using AST_Declarationscope)
final class UserNamespace : Namespace {

public:
	this(Symbol parent_, AST_DeclarationScope scope_, DeclarationEnvironment env) {
		this.scope_ = scope_;
		env_ = env;

		foreach (AST_Declaration decl; scope_.allDeclarations)
			identifierGroups_.require(decl.declarationIdentifier, new IdentifierGroup());
	}

public:
	override Symbol[] resolveIdentifier(Identifier identifier) {
		if (IdentifierGroup* group = identifier in identifierGroups_)
			return group.symbols;

		return null;

	}

private:
	AST_DeclarationScope scope_;
	DeclarationEnvironment env_;
	Symbol parent_;
	IdentifierGroup[Identifier] identifierGroups_;

private:
	class IdentifierGroup : Identifiable {
		mixin TaskGuard!"declarationExecution";

	public:
		this(AST_Declaration[] declarations) {
			declarations_ = declarations;
		}

	public:
		pragma(inline) Symbol[] symbols() {
			enforceDone_declarationExecution();
			return symbolsWIP_;
		}

	public:
		override string str(ToStringFlags flags = 0) {
			return parent_.str(flags);
		}

	protected:
		void execute_declarationExecution() {
			foreach (AST_Declaration decl; declarations_)
				decl.executeDeclaration(symbolsWIP_, env_);
		}

	private:
		AST_Declaration[] declarations_;
		Symbol[] symbolsWIP_; ///< Obtained by "declarationExecution" task

	}

}
