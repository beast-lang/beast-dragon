module t_typeparamconstants;

Void foo1( Operator ) {

}

Void foo1( Void ) {

}

Void foo1( Bool ) {

}

Void ok1() {
	foo1( Operator );
	foo1( Void );
	foo1( Bool );
}

Void err1() {
	foo1( Int ); //! error: noMatchingOverload
}

Void err2() {
	foo1( Type ); //! error: noMatchingOverload
}

Void foo2( Bool ) {

}

Void foo2( Bool b ) {

}

Void ok2() {
	foo2( Bool );
	foo2( true );
	foo2( false );
}

Void err3() {
	foo2( Int ); //! error: noMatchingOverload
}