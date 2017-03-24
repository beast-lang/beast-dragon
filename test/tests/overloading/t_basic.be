module t_basic;

Void foo1() {

}
Void foo1( Bool a, Bool b ) {

}

Void foo2() {

}
Void foo2() {

}

Void foo3( Bool b ) {

}

Void main() {
	foo1();
	foo1( true, false );
	foo3( true );
}

Void fail1() {
	foo1( false ); //! error: noMatchingOverload
}

Void fail2() {
	foo1( false, true, false ); //! error: noMatchingOverload
}

Void fail3() {
	foo2(); //! error: ambiguousResolution
}

Void fail4() {
	foo0(); //! error: unknownIdentifier
}

Void fail5() {
	foo3( :test ); //! error: unknownIdentifier
}