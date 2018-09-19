module beast.code.ast.decl.function_;

import beast.code.ast.decl.toolkit;
import beast.code.ast.identifier;
import beast.code.ast.expr.parentcomma;
import beast.code.ast.stmt.codeblock;
import beast.code.data.scope_.root;
import beast.code.data.function_.usrstcrt;
import beast.code.data.function_.usrmemrt;
import beast.code.data.function_.paramlist;
import beast.code.data.function_.usrstcnrt;

final class AST_FunctionDeclaration : AST_Declaration {

public:
	static bool canParse() {
		assert(0);
	}

	/// Continues parsing after "@deco Type name" part ( argument list follows )
	static AST_Declaration parse(CodeLocationGuard _gd, AST_DecorationList decorationList, AST_Expression returnType, AST_Identifier identifier) {
		AST_FunctionDeclaration result = new AST_FunctionDeclaration;
		result.decorationList = decorationList;
		result.returnType = returnType;
		result.identifier = identifier;

		result.parameterList = AST_ParentCommaExpression.parse();
		result.body_ = AST_CodeBlockStatement.parse();

		result.codeLocation = _gd.get();
		return result;
	}

public:
	override void executeDeclarations(DeclarationEnvironment env, void delegate(Symbol) sink) {
		const auto __gd = ErrorGuard(codeLocation);

		FunctionDeclarationData declData = new FunctionDeclarationData(env);
		DecorationList decorations = new DecorationList(decorationList);

		// Apply possible decorators in the variableDeclarationModifier context
		decorations.apply_functionDeclarationModifier(declData);

		auto paramList = new FunctionParameterList(parameterList);

		if (declData.isStatic && !declData.isCtime && paramList.isRuntimeParameterList)
			sink(new Symbol_UserStaticRuntimeFunction(this, decorations, declData, paramList));

		else if (!declData.isStatic && !declData.isCtime && paramList.isRuntimeParameterList)
			sink(new Symbol_UserMemberRuntimeFunction(this, decorations, declData, paramList));

		else if (declData.isStatic && !declData.isCtime && !paramList.isRuntimeParameterList)
			sink(new Symbol_UserStaticNonRuntimeFunction(this, decorations, declData, paramList));

		else if (!declData.isStatic && !declData.isCtime && !paramList.isRuntimeParameterList)
			berror(E.notImplemented, "Member functions with @ctime parameters are not implemented yet");

		else
			berror(E.notImplemented, "@ctime functions are not implemented yet");
	}

	override void buildStatementCode(DeclarationEnvironment env, CodeBuilder cb) {
		berror(E.notImplemented, "Nested functions are not implemented yet");
	}

public:
	AST_DecorationList decorationList;
	AST_Expression returnType;
	AST_ParentCommaExpression parameterList;
	AST_Identifier identifier;
	AST_CodeBlockStatement body_;

protected:
	override SubnodesRange _subnodes() {
		// Decoration list can be inherited from decoration block or something, in that case we should not consider it a subnodes
		return nodeRange(returnType, identifier, parameterList, decorationList.codeLocation.isInside(codeLocation) ? decorationList : null);
	}

}

final class FunctionDeclarationData {

public:
	this(DeclarationEnvironment env) {
		this.env = env;

		isCtime = env.isCtime;
		isStatic = env.isStatic;
	}

public:
	DeclarationEnvironment env;

public:
	bool isCtime;
	bool isStatic;

}
