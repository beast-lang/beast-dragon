module beast.code.ast.stmt.delete_;

import beast.code.ast.toolkit;
import beast.code.entity.var.tmplocal;
import beast.code.entity.util.reinterpret;

final class AST_DeleteStatement : AST_Statement {

public:
	pragma(inline) static bool canParse() {
		return currentToken == Token.Keyword.delete_;
	}

	/// Continues parsing after decoration list
	static AST_DeleteStatement parse(CodeLocationGuard _gd, AST_DecorationList decorationList) {
		auto result = new AST_DeleteStatement;
		benforce(decorationList is null, E.invalidDecoration, "Decorating a delete statement is not allowed");

		currentToken.expectAndNext(Token.Keyword.delete_);
		result.expr = AST_Expression.parse();
		currentToken.expectAndNext(Token.Special.semicolon);

		result.codeLocation = _gd.get();
		return result;
	}

public:
	AST_Expression expr;

public:
	override void buildStatementCode(DeclarationEnvironment env, CodeBuilder cb) {
		const auto __gd = ErrorGuard(codeLocation);

		cb.build_scope((cb) {
			auto val = expr.buildSemanticTree_single();
			auto refType = val.dataType;

			benforce(refType.isReferenceType !is null, E.referenceTypeRequired, "Delete can only be used on references, not %s".format(refType.identificationString));

			auto var = new DataEntity_TmpLocalVariable(refType);
			cb.build_localVariableDefinition(var);
			cb.build_copyCtor(var, val);

			// Call the destructor on referenced memory
			var.expectResolveIdentifier(ID!"#data").single.expectResolveIdentifier(ID!"#dtor").resolveCall(expr, true).buildCode(cb);

			// Call free
			coreFunc.free.dataEntity.resolveCall(expr, true, new DataEntity_ReinterpretCast(var, coreType.Pointer)).buildCode(cb);
		});
	}

protected:
	override SubnodesRange _subnodes() {
		return nodeRange(expr);
	}

}
