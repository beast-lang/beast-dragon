module beast.util.identifiable;

/// An interface for anything that needs identifying in the console (provides identificationString function)
interface Identifiable {

public:
	string identificationString();

public:
	final string toString() const {
		return (cast(Identifiable) this).identificationString();
	}

}
