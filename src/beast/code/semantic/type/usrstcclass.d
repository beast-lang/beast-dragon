module beast.code.semantic.type.usrstcclass;

import beast.code.semantic.toolkit;
import beast.code.semantic.type.stcclass;
import beast.code.ast.decl.class_;
import beast.code.decorationlist;
import beast.code.semantic.codenamespace.user;
import beast.code.ast.decl.env;
import std.algorithm.comparison : min;
import beast.code.hwenv.hwenv;
import beast.code.semantic.codenamespace.namespace;

final class Symbol_UserStaticClass : Symbol_StaticClass {
	mixin TaskGuard!"instanceSizeObtaining";

public:
	this(AST_Class ast, DecorationList decorationList, ClassDeclarationData declData) {
		// Identifier (thus ast) must be available even when constructing parent class
		ast_ = ast;

		decorationList.enforceAllResolved();

		super(declData.env.staticMembersParent);

		assert(!declData.isCtime);
		assert(declData.isStatic);
		assert(ast);

		namespace_ = new UserNamespace(this, &execute_membersObtaining);
	}

	override Identifier identifier() {
		return ast_.identifier;
	}

	override size_t instanceSize() {
		enforceDone_instanceSizeObtaining();
		return instanceSizeWIP_;
	}

	override AST_Node ast() {
		return ast_;
	}

	override Namespace namespace() {
		return namespace_;
	}

private:
	final Symbol[] execute_membersObtaining() {
		scope env = DeclarationEnvironment.newClass();
		env.staticMembersParent = staticData_;
		env.parentType = this;
		env.enforceDone_memberOffsetObtaining = &enforceDone_instanceSizeObtaining;

		return ast_.declarationScope.executeDeclarations(env).inRootDataScope(parent);
	}

	final void execute_instanceSizeObtaining() {
		size_t instanceSize = 0;

		foreach (mem; namespace_.members) {
			if (auto memVar = mem.isMemberVariable) {
				size_t memSize = memVar.dataType.instanceSize;

				if (!memSize)
					continue;

				size_t roundTo = min(memSize, hardwareEnvironment.pointerSize);

				// We round the instance size so that member is aligned to its size
				instanceSize += (roundTo - instanceSize % roundTo) % roundTo;
				memVar.setParentThisOffsetWIP__ONLYFROMPARENTCLASS(instanceSize);
				instanceSize += memSize;
			}
		}

		instanceSizeWIP_ = instanceSize;
	}

private:
	AST_Class ast_;
	UserNamespace namespace_;
	size_t instanceSizeWIP_;

}
