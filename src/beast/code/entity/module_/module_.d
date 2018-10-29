module beast.code.entity.module_.module_;

import beast.code.entity.toolkit;
import beast.code.entity.codenamespace.namespace;
import beast.core.error.error;

/// Module as a symbol
/// See also Module from beast.core.project.module_ with module as project file
abstract class Symbol_Module : Symbol {

public:
	this() {
		staticData_ = new Data(this, MatchLevel.fullMatch);
		importSpaceData_ = new ImportSpaceData(this);
	}

public:
	final override DeclType declarationType() {
		return DeclType.module_;
	}

public:
	final override DataEntity dataEntity(MatchLevel matchLevel = MatchLevel.fullMatch, DataEntity instance = null) {
		if (matchLevel != MatchLevel.fullMatch)
			return new Data(this, matchLevel);
		else
			return staticData_;
	}

protected:
	abstract Namespace namespace();

private:
	Data staticData_;
	ImportSpaceData importSpaceData_;

private:
	final static class Data : SymbolRelatedDataEntity {

	public:
		this(Symbol_Module sym, MatchLevel matchLevel) {
			super(sym, matchLevel);

			sym_ = sym;
		}

	public:
		override Symbol_Type dataType() {
			// TODO: Module reflection type
			return coreType.Void;
		}

		override bool isCtime() {
			return true;
		}

		override DataEntity parent() {
			return sym_.importSpaceData_;
		}

	protected:
		protected override Overloadset _resolveIdentifier_main(Identifier id, MatchLevel matchLevel) {
			// TODO: Copy this to Module core type
			if (auto result = sym_.namespace.resolveIdentifier(id, null, matchLevel))
				return result;

			return Overloadset();
		}

	private:
		Symbol_Module sym_;

	}

	final static class ImportSpaceData : DataEntity {

	public:
		this(Symbol_Module sym) {
			super(MatchLevel.fullMatch);
			sym_ = sym;
		}

	public:
		override Symbol_Type dataType() {
			// TODO: Maybe better dataType?
			return coreType.Void;
		}

		override bool isCtime() {
			return true;
		}

		override DataEntity parent() {
			return null;
		}

	public:
		override AST_Node ast() {
			return null;
		}

		override Hash outerHash() {
			return Hash();
		}

		override string identification() {
			return null;
		}

		override string identificationString_noPrefix() {
			return null;
		}

	protected:
		override Overloadset _resolveIdentifier_main(Identifier id, MatchLevel matchLevel) {
			// TODO: imports and public imports

			if (sym_ !is coreLibrary.module_) {
				if (auto result = coreLibrary.module_.dataEntity.resolveIdentifier(id, matchLevel))
					return result;
			}

			return Overloadset();
		}

	private:
		Symbol_Module sym_;

	}

}
