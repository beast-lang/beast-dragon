module t_simple;

Void test( @ctime Int i ) {
	print( i );
}

Void test2( auto x ) {
	print( x.#instanceSize );
	print( x );
}

Void main() {
	test( 5 ); //! stdout: 5
	test( 8 ); //! stdout: 8

	test2( 5 ); //! stdout: 45
	test2( true ); //! stdout: 11
	test2( false ); //! stdout: 10
	test2( 12.to( Int64 ) ); //! stdout: 812
}