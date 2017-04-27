module t_smartopts;

auto max( auto a, a.#type b ) {
	if( a > b )
		return a;
	else
		return b;
}

auto max( auto a, a.#type b, b.#type c ) {
	if( a > b )
		return max( a, c );
	else
		return max( b, c );
}

Void test() {
	assert( max( 5, 8 ) == 8 );
	assert( max( 8, 5 ) == 8 );

	assert( max( 1, 3, 2 ) == 3 );
	assert( max( 3, 2, 1 ) == 3 );
	assert( max( 1, 2, 3 ) == 3 );
	assert( max( 3, 1, 2 ) == 3 );
	assert( max( 2, 1, 3 ) == 3 );
	assert( max( 2, 3, 1 ) == 3 );
}

Void main() {
	test();
	@ctime test();

	print( max( 8, 8954, -41 ) ); //! stdout: 8954
}