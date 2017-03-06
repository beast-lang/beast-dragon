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
			ExpandedFunctionParameter result = new ExpandedFunctionParameter( );
			result.ast = expr;

			// Declaration -> standard parameter
			if ( AST_VariableDeclarationExpression decl = expr.isVariableDeclaration ) {
				// Auto expressions cannot be expanded
				if ( decl.dataType.isAutoExpression )
					assert( 0, "Cannot expand auto parameter" );

				result.identifier = decl.identifier.identifier;
				result.dataType = decl.dataType.ctExec( coreLibrary.types.Type, scope_ ).readType( );
			}
			// Constant value parameter
			else {
				DataEntity constVal = expr.buildSemanticTree_single( null, scope_ );

				result.dataType = constVal.dataType;
				result.constValue = constVal.ctExec( scope_ );
			}

			assert( result.dataType );
			return result;
		}

	public:
		/// Can be null for const-value parameters
		Identifier identifier;

		/// Data type of the parameter
		Symbol_Type dataType;

		/// If the parameter is const-value (something like template specialization), this points to the value
		MemoryPtr constValue;

		/// Index of the paramter
		size_t index;

		AST_Expression ast;

	public:
		Hash outerHash( ) {
			return dataType.outerHash + Hash( index );
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
