module t_constvalparams;

Void test( 4 ) {
	print( 14 );
}

Void test( 5 ) {
	print( 15 );
}

Void main() {
	test( 4 ); //! stdout: 14
	test( 5 ); //! stdout: 15
	test( @ctime 2 + 2 ); //! stdout: 14
}