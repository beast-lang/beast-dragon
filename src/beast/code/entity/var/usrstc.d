module beast.code.entity.var.usrstc;

import beast.code.entity.toolkit;
import beast.code.entity.var.static_;
import beast.code.decorationlist;
import beast.code.ast.decl.variable;
import beast.code.entity.scope_.root;
import beast.backend.ctime.codebuilder;
import beast.code.entity.util.subst;
import beast.core.ctxctimeguard;

/// User (programmer) defined static variable
final class Symbol_UserStaticVariable : Symbol_StaticVariable {
	mixin TaskGuard!"typeDeduction";
	mixin TaskGuard!"memoryAllocation";

public:
	this(AST_VariableDeclaration ast, DecorationList decorationList, VariableDeclarationData data) {
		super(data.env.staticMembersParent);
		assert(data.isStatic);

		ast_ = ast;
		decorationList_ = decorationList;
		isCtime_ = data.isCtime;

		taskManager.delayedIssueJob({ enforceDone_memoryAllocation(); });
	}

public:
	override Identifier identifier() {
		return ast_.identifier;
	}

	override Symbol_Type dataType() {
		enforceDone_typeDeduction();
		return dataTypeWIP_;
	}

	override AST_Node ast() {
		return ast_;
	}

	override MemoryPtr memoryPtr() {
		enforceDone_memoryAllocation();
		return memoryPtrWIP_;
	}

	override bool isCtime() {
		return isCtime_;
	}

private:
	DecorationList decorationList_;
	AST_VariableDeclaration ast_;
	Symbol_Type dataTypeWIP_;
	MemoryPtr memoryPtrWIP_;
	bool isCtime_;

private:
	void execute_typeDeduction() {
		const auto _gd = ErrorGuard(ast_.dataType.codeLocation);

		// When the type is auto (deduced), the type deduction actually takes place in memoryAllocation
		if (ast_.dataType.isAutoExpression)
			enforceDone_memoryAllocation();
		else
			dataTypeWIP_ = ast_.dataType.ctExec_asType.inRootDataScope(parent).inStandaloneSession;

		benforce(dataTypeWIP_.instanceSize > 0, E.zeroSizeVariable, "Type '%s' has zero instance size".format(dataTypeWIP_.identificationString));

		decorationList_.enforceAllResolved();
	}

	void execute_memoryAllocation() {
		const auto _gd = ErrorGuard(ast_.dataType.codeLocation);

		with (memoryManager.session(SessionPolicy.doNotWatchCtChanges)) {
			auto _sgd = new RootDataScope(parent).scopeGuard;

			DataEntity valueEntity;
			if (ast_.dataType.isAutoExpression) {
				benforce(ast_.value !is null, E.missingInitValue, "Variable '%s.%s' definition needs implicit value for type deduction".format(parent.identificationString, identifier.str));

				valueEntity = ast_.value.buildSemanticTree_single();
				dataTypeWIP_ = valueEntity.dataType;
			}
			else
				enforceDone_typeDeduction();

			// We allocate a memory block
			MemoryBlock block = memoryManager.allocBlock(dataTypeWIP_.instanceSize, isCtime_ ? MemoryBlock.Flags.ctime : MemoryBlock.Flags.noFlag);
			block.markDoNotGCAtSessionEnd();
			block.relatedDataEntity = dataEntity;
			block.identifier = identifier.str;

			memoryPtrWIP_ = block.startPtr;

			// We can't use this.dataEntity because that would cause a dependency loop (as we would require memoryPtr for this in it)
			DataEntity substEntity = new SubstitutiveDataEntity(memoryPtrWIP_, dataTypeWIP_);

			if (isCtime_) {
				auto __cgd = ContextCtimeGuard(true);
				scope cb = new CodeBuilder_Ctime();
				

				// If the variable is ctime, we execute the constructor in ctime
				if (valueEntity)
					ast_.buildConstructor(substEntity, valueEntity, cb);
				else
					ast_.buildConstructor(substEntity, ast_.value, cb);

				cb.result.destroy();
			}
			else {
				// Otherwise, we add it to the init block
				project.backend.buildInitCode((cb) => cb.build_scope((cb) { //
						if (valueEntity)
							ast_.buildConstructor(substEntity, valueEntity, cb);
						else
							ast_.buildConstructor(substEntity, ast_.value, cb).inRootDataScope(parent);
					}).inSession(SessionPolicy.watchCtChanges));
			}
		}
	}

}
