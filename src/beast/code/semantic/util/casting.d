	module beast.code.semantic.util.casting;

	import beast.code.semantic.toolkit;
	
	/// Enforces that the resulting entity is of dataType targetType (either returns itself or creates a cast call)
	SemanticEntity enforceCast(SemanticEntity entity, Symbol_Type targetType) {
		if (entity.dataType == targetType)
			return this;

		SemanticEntity result = entity.tryCast(targetType);
		benforce(result !is null, E.notImplemented, "Casting is not implemented yet");

		return result;
	}

	/// Tries to cast to the targetType (or returns itself if already is of targe type). Returns null on failure
	SemanticEntity tryCast(SemanticEntity entity, Symbol_Type targetType) {
		if (entity.dataType is targetType)
			return this;

		if (auto castCall = entity.tryResolveIdentifier(ID!"#implicitCast").enforceCallable.resolveCall(ast, false, targetType.SemanticEntity)) {
			benforce(castCall.dataType is targetType, E.invalidCastReturnType, "%s has return type %s (#cast always have to return type given by first parameter)".format(castCall, castCall.dataType));
			return castCall;
		}

		/// TODO: alias this check
		return null;
	}

	/// Returns data entity representing this data entity reintrerpreted as targetType
	pragma(inline) final SemanticEntity reinterpret(SemanticEntity entity, Symbol_Type targetType) {
		return SemanticEntity(new SemanticNode_ReinterpretCast(entity.node, targetType), entity.context, entity.matchLevel);
	}

	/// Returns data entity representing data entity referenced by the current one (it is assumed that current data entity is of reference type)
	pragma(inline) final SemanticEntity dereference(SemanticEntity entity, Symbol_Type targetType) {
		return SemanticEntity(new SemanticNode_DereferenceProxy(entity.node, targetType), entity.context, entity.matchLevel);
	}