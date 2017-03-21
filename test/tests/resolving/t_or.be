module t_or;

Bool staticVar;

Bool foo() {

}

Void poo( Bool b ) {

}

Void main() {
	foo() || true;
	poo( staticVar || false );
	true || ( false && true );
	true || false || true;
	true.#operator( Operator.binOr, true );
}

Void err1() {
	true || poo( false ); //! error: cannotResolve
}

Void err2() {
	Bool.#operator( :binOr, false ); //! error: noMatchingOverload
}