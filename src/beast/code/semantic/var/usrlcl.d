module beast.code.semantic.var.usrlcl;

import beast.code.semantic.toolkit;
import beast.code.semantic.var.local;
import beast.code.decorationlist;
import beast.code.ast.decl.variable;
import beast.code.ast.expr.vardecl;
import beast.code.ast.expr.expression;

final class DataEntity_UserLocalVariable : DataEntity_LocalVariable {

public:
	this(AST_VariableDeclaration ast, DecorationList decorationList, VariableDeclarationData data) {
		ast_ = ast;
		identifier_ = ast.identifier.identifier;

		this(ast.identifier, ast.dataType, decorationList, data);
	}

	this(AST_VariableDeclarationExpression ast, DecorationList decorationList, VariableDeclarationData data) {
		ast_ = ast;

		this(ast.identifier, ast.dataType, decorationList, data);
	}

	private this(Identifier id, AST_Expression typeExpression, DecorationList decorationList, VariableDeclarationData data) {
		const auto _gd = ErrorGuard(this);

		// Deduce data type
		Symbol_Type dataType = typeExpression.ctExec_asType().inLocalDataScope;

		this(identifier, dataType, decorationList, data);
	}

	this(Identifier id, Symbol_Type dataType, DecorationList decorationList, VariableDeclarationData data) {
		identifier_ = id;

		benforce(dataType.instanceSize > 0, E.zeroSizeVariable, "Variable %s of type %s has zero size".format(identifier_.str, dataType.identificationString));

		super(dataType);

		decorationList.enforceAllResolved();
	}

public:
	final override Identifier identifier() {
		return identifier_;
	}

	final override AST_Node ast() {
		return ast_;
	}

public:
	override void allocate(bool isCtime) {
		allocate_(isCtime, MemoryBlock.Flags.noFlag);
		memoryBlock_.identifier = identifier_.str;
	}

private:
	Identifier identifier_;
	AST_Node ast_;

}
