module beast.code.ast.decl.env;

import beast.code.ast.decl.toolkit;
import beast.code.semantic.type.type;
import beast.code.semantic.codenamespace.namespace;
import beast.code.semantic.stcmemmerger.d;
import beast.code.semantic.function_.rt;

/// Implicit declaration arguments
final class DeclarationEnvironment {

public:
	static DeclarationEnvironment newModule() {
		DeclarationEnvironment result = new DeclarationEnvironment;
		return result;
	}

	static DeclarationEnvironment newFunctionBody() {
		DeclarationEnvironment result = new DeclarationEnvironment;
		result.isStatic = false;
		return result;
	}

	static DeclarationEnvironment newClass() {
		DeclarationEnvironment result = new DeclarationEnvironment;
		result.isStatic = false;
		return result;
	}

public:
	DeclarationEnvironment dup() {
		auto result = new DeclarationEnvironment();
		result.isStatic = isStatic;
		result.isCtime = isCtime;

		result.parentType = parentType;
		result.enforceDone_memberOffsetObtaining = enforceDone_memberOffsetObtaining;
		result.staticMembersParent = staticMembersParent;
		result.staticMemberMerger = staticMemberMerger;
		result.functionReturnType = functionReturnType;

		return result;
	}

public:
	bool isStatic = true;
	bool isCtime = false;

public:
	Symbol_Type parentType;

	/// Delegate that is used when declaring class members
	/// Points to parent class function that enforces that members have correct parent offset (bytes from this) value set
	void delegate() enforceDone_memberOffsetObtaining;

	/// Parent for static members
	DataEntity staticMembersParent;

	StaticMemberMerger staticMemberMerger;

	/// When in function, this varaible is used for inferring expected types for return statements
	/// Can be null (when function return type is auto) -> then the first return in the code sets it
	Symbol_Type functionReturnType;

}
