module beast.code.semantic.util.cached;

import beast.code.semantic.toolkit;
import beast.code.semantic.util.btsp;
import beast.code.semantic.var.tmplocal;

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
			auto var = new DataEntity_TmpLocalVariable(sourceEntity.dataType);
			auto varCtor = var.getCopyCtor(sourceEntity);

			reference = var;
			definition = new DataEntity_Bootstrap(sourceEntity.identifier, sourceEntity.dataType, sourceEntity.parent, false, (cb) {
				auto _gd = ErrorGuard(sourceEntity.ast.codeLocation);

				cb.build_localVariableDefinition(var);
				varCtor.buildCode(cb);
				var.buildCode(cb);
			});
		}
	}

};
