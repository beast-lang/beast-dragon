module beast.util.identifiable;

interface Identifiable {

public:
	string str(ToStringFlags flags = 0);

public:
	final override string toString() const {
		return (cast(Identifiable) this).str(0);
	}

}

alias ToStringFlags = uint;
enum ToString : ToStringFlags {
	hideType = 1 << 0,

	parentMask = hideType,
	symbolParentMask = hideType
}