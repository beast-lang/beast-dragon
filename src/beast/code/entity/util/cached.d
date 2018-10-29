module beast.code.entity.util.cached;

import beast.code.entity.toolkit;
import beast.code.entity.util.btsp;
import beast.code.entity.var.tmplocal;
import beast.corelib.toolkit;
import beast.corelib.type.reference;

/// Structure of two DataEntities constructed from one source DataEntity
/// If the dataEntity is ctime, it executes (in a subsession) it and sets both member entitites to the result
/// If not, it creates a definition and reference data entity - definition data entity should be used the first time acessing the source entity (it creates a copy of sourceEntity)
/// Further access should be via reference entity, which referes to the cached value
struct CachedDataEntity {

public:
	DataEntity definition;
	DataEntity reference;

public:
	this(DataEntity sourceEntity) {
		if (sourceEntity.dataType.isCtime)
			definition = reference = sourceEntity.ctExec_asDataEntity.inSubSession;

		else {
			Symbol_Type_Reference refType = coreType.Reference.referenceTypeOf(sourceEntity.dataType);
			auto var = new DataEntity_TmpLocalVariable(refType);
			auto varCtor = refType.expectResolveIdentifier_direct(ID!"#ctor", var).resolveCall(sourceEntity.ast, true, sourceEntity);//var.getCopyCtor(sourceEntity);

			reference = var;
			definition = new DataEntity_Bootstrap(sourceEntity.identifier, refType, sourceEntity.parent, false, (cb) {
				auto _gd = ErrorGuard(sourceEntity.ast.codeLocation);

				cb.build_localVariableDefinition(var);
				varCtor.buildCode(cb);
				var.buildCode(cb);
			});
		}
	}

};
