module beast.code.data.function_.expandedparameter;

import beast.code.toolkit;
import beast.code.ast.identifier;
import beast.code.ast.expr.expression;
import beast.code.ast.expr.vardecl;

/// Expanded function parameter
final class ExpandedFunctionParameter {

public:
	/// Tries to expand expression into a function parameter.
	static ExpandedFunctionParameter process( AST_Expression expr, DataScope scope_ ) {
		if ( AST_VariableDeclarationExpression decl = expr.isVariableDeclaration ) {
			// Auto expressions cannot be expanded
			if ( decl.type.isAutoExpression )
				assert( 0, "Cannot expand auto parameter" );

			ExpandedFunctionParameter result = new ExpandedFunctionParameter( );
			result.identifier = decl.identifier.identifier;
			result.type = decl.type.ctExec( coreLibrary.types.Type, scope_ ).readType();

			return result;
		}

		ExpandedFunctionParameter result = new ExpandedFunctionParameter( );
		DataEntity constVal = expr.buildSemanticTree( null, scope_ );

		result.type = constVal.dataType;
		result.constValue = constVal.ctExec( scope_ );
		return result;
	}

public:
	/// Can be null for const-value parameters
	Identifier identifier;

	/// Data type of the parameter
	Symbol_Type type;

	/// If the parameter is const-value (something like template specialization), this points to the value
	MemoryPtr constValue;

}
