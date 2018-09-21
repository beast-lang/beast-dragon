module beast.code.semantic.function_.paramlist;

import beast.code.semantic.function_.toolkit;
import beast.code.ast.expr.parentcomma;
import beast.code.decorationlist;
import beast.code.ast.expr.decorated;
import beast.code.ast.expr.vardecl;
import beast.code.semantic.function_.param;

final class FunctionParameterList {

public:
	this(AST_ParentCommaExpression ast) {
		foreach (param; ast.items) {
			auto decorated = param.isDecoratedExpression;
			auto var = decorated ? decorated.baseExpression.isVariableDeclaration : param.isVariableDeclaration;

			// If the param is not variable declaration, it is a constval argument -> we leave it as is, including decorators
			if (!var) {
				paramData_ ~= ParamData(param, true);
				continue;
			}

			benforce(var.value is null, E.notImplemented, "Default parameter values are not implemented yet");

			isCtimeParameterList_ |= var.dataType.isAutoExpression !is null;

			DecorationList decoList;
			if (decorated) {
				decoList = new DecorationList(decorated.decorationList);

				auto paramData = new FunctionParameterDecorationData();
				decoList.apply_functionParameterModifier(paramData);

				isCtimeParameterList_ |= paramData.isCtime;

				paramData_ ~= ParamData(var, paramData.isCtime, decoList);
			}
			else
				paramData_ ~= ParamData(var);
		}
	}

public:
	bool isCtimeParameterList() {
		return isCtimeParameterList_;
	}

	bool isRuntimeParameterList() {
		return !isCtimeParameterList_;
	}

	size_t parameterCount() {
		return paramData_.length;
	}

	ParamData paramData(size_t index) {
		return paramData_[index];
	}

public:
	/// Expands runtime parameter list
	ExpandedFunctionParameter[] expandAsRuntimeParameterList() {
		assert(isRuntimeParameterList);

		ExpandedFunctionParameter[] result;
		size_t runtimeIndex;

		foreach (index, paramData; paramData_) {
			auto param = new ExpandedFunctionParameter();
			param.ast = paramData.ast;
			param.index = index;

			// Declaration -> standard parameter
			if (AST_VariableDeclarationExpression decl = paramData.ast.isVariableDeclaration) {
				param.identifier = decl.identifier.identifier;
				param.dataType = decl.dataType.ctExec_asType();
				param.runtimeIndex = runtimeIndex++;

				benforce(param.dataType.instanceSize > 0, E.zeroSizeVariable, "Parameter %s has instance size 0".format(index + 1));

				auto paramEntity = new DataEntity_FunctionParameter(param, false);
				currentScope.addEntity(paramEntity);
			}
			// Constant value parameter
			else {
				DataEntity constVal = paramData.ast.buildSemanticTree_single();

				param.dataType = constVal.dataType;
				param.constValue = constVal.ctExec().keepForever;
			}

			assert(param.dataType);
			result ~= param;
		}

		return result;
	}

private:
	ParamData[] paramData_;
	bool isCtimeParameterList_;

private:
	struct ParamData {
		/// AST node of the variable declaration or constval argument
		AST_Expression ast;

		bool isCtime;

		/// Decoration list or null if no decorations (also null for constval arguments)
		DecorationList decorationList;
	}

}
