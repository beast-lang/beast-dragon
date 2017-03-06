module beast.code.data.function_.expandedparameter;

import beast.code.toolkit;
import beast.code.ast.identifier;
import beast.code.ast.expr.expression;
import beast.code.ast.expr.vardecl;

/// Expanded function parameter
final class ExpandedFunctionParameter : Identifiable {

public:
	/// Tries to expand expression into a function parameter.
	static ExpandedFunctionParameter process( AST_Expression expr, DataScope scope_ ) {
		if ( AST_VariableDeclarationExpression decl = expr.isVariableDeclaration ) {
			// Auto expressions cannot be expanded
			if ( decl.dataType.isAutoExpression )
				assert( 0, "Cannot expand auto parameter" );

			ExpandedFunctionParameter result = new ExpandedFunctionParameter( );
			result.identifier = decl.identifier.identifier;
			result.dataType = decl.dataType.ctExec( coreLibrary.types.Type, scope_ ).readType( );

			return result;
		}

		ExpandedFunctionParameter result = new ExpandedFunctionParameter( );
		DataEntity constVal = expr.buildSemanticTree_single( null, scope_ );

		result.dataType = constVal.dataType;
		result.constValue = constVal.ctExec( scope_ );
		return result;
	}

public:
	/// Can be null for const-value parameters
	Identifier identifier;

	/// Data type of the parameter
	Symbol_Type dataType;

	/// If the parameter is const-value (something like template specialization), this points to the value
	MemoryPtr constValue;

public:
	Hash outerHash() {
		return dataType.outerHash + identifier.hash;
	}

	override string identificationString( ) {
		string result;
		result ~= dataType.identificationString;

		if ( identifier )
			result ~= " " ~ identifier.str;

		if ( constValue )
			result ~= " = CONST";

		return result;
	}

}
