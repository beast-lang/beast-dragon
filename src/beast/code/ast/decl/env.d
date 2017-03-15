module beast.code.ast.decl.env;

import beast.code.ast.decl.toolkit;
import beast.code.data.type.type;
import beast.code.data.codenamespace.namespace;
import beast.code.data.stcmemmerger.d;

/// Implicit declaration arguments
final class DeclarationEnvironment {

	public:
		static DeclarationEnvironment newModule( ) {
			DeclarationEnvironment result = new DeclarationEnvironment;
			return result;
		}

		static DeclarationEnvironment newFunctionBody( ) {
			DeclarationEnvironment result = new DeclarationEnvironment;
			result.isStatic = false;
			return result;
		}

	public:
		bool isStatic = true;
		bool isCtime = false;

	public:
		Symbol_Type parentType;

		/// Parent for static members
		DataEntity staticMembersParent;

		/// 'Parent' for local variables
		DataScope scope_;

		StaticMemberMerger staticMemberMerger;

}