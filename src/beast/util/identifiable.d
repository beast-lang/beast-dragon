module beast.util.identifiable;

interface Identifiable {

public:
	string identificationString();

public:
	final string toString() const {
		return (cast(Identifiable) this).identificationString();
	}

}
