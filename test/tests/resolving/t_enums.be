module t_enums;

Void foo1( Operator op ) {

}

Void foo2( Operator op ) {

}

Void foo2( Operator op ) {

}

Void foo3( Operator.binOrR ) {

}

Void foo3( Operator.binOr ) {

}

Void main() {
	foo1( Operator.binOr );
	foo1( Operator.binOrR );
	foo1( :binOr );
	foo1( :funcCall );

	foo3( :binOrR );
	foo3( :binOr );
	foo3( Operator.binOr );
}

Void err1() {
	foo1( Operator ); //! error: noMatchingOverload
}

Void err2() {
	foo2( :xx ); //! error: noMatchingOverload
}

Void err3( Operatora op ) { //! error: unknownIdentifier

}

Void err4() {
	foo2( Operator.binOr ); //! error: ambiguousResolution
}

Void err5() {
	foo2( :funcCall ); //! error: ambiguousResolution
}

Void err6() {
	Operator o;
	foo3( o ); //! error: noMatchingOverload
}

Void err7() {
	foo1( :xx ); //! error: unknownIdentifier
}
