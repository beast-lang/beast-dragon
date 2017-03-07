module t_opor;

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
}

Void err1() {
	true || poo( false ); //! error: cannotResolve
}