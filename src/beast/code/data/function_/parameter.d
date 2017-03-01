module beast.code.data.function_.parameter;

import beast.code.toolkit;
import beast.code.ast.identifier;
import beast.code.ast.expr.expression;
import beast.code.ast.expr.vardecl;

/// Expanded function parameter
final class FunctionParameter {

public:
	/// Tries to expand expression into a function parameter. Return null on failure ('correct' failure - for example auto or variadic parameter)
	static FunctionParameter process( AST_Expression expr, DataEntity parent ) {
		if ( AST_VariableDeclarationExpression e = expr.isVariableDeclaration ) {
			if ( e.type.isAutoType )
				return null;

			FunctionParameter result = new FunctionParameter( );
			result.identifier = e.identifier.identifier;
			result.type = e.type.standaloneCtExec( coreLibrary.types.Type, parent ).readType();

			return result;
		}

		FunctionParameter result = new FunctionParameter( );
		DataEntity constVal = e.buildSemanticTree();

		//result.type = 
	}

public:
	/// Can be null for const-value parameters
	Identifier identifier;

	/// Data type of the parameter
	Symbol_Type type;

	/// If the parameter is const-value (something like template specialization), this points to the value
	MemoryPtr constValue;

}
