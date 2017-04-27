module t_errors;

auto max( auto a, a.#type b ) {
	if( a > b )
		return a;
	else
		return b;
}

auto max( auto a, a.#type b ) {
	if( a > b )
		return a;
	else
		return b;
}

auto fineMax( auto a, a.#type b ) {
	if( a > b )
		return a;
	else
		return b;
}

Void err1() {
	max( 3, 5 ); //! error: ambiguousResolution
}

Void err2() {
	fineMax( 3, true ); //! error: noMatchingOverload
}

Void test3( Int x, x ) { //! error: valueNotCtime

}

Void err3() {
	test3( 5, 3 );
}

Void test4( @ctime Int x, x ) {

}

Void err4() {
	test4( 5, 6 ); //! error: noMatchingOverload
}

Void main() {
	test4( 1, 1 );
	test4( 5, 5 );
}