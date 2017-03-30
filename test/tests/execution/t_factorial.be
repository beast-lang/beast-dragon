module t_factorial;

Int factorial( Int x ) {
	Int result = 1;

	while( x > 1 ) {
		result = result * x;
		x = x - 1;
	}

	return result;
}

Int recursiveFactorial( Int x ) {
	if( x <= 1 )
		return 1;
	else
		return x * recursiveFactorial( x - 1 );
}

Int tests() {
	assert( factorial( 0 ) == 1 );
	assert( factorial( 1 ) == 1 );
	assert( factorial( 2 ) == 2 );
	assert( factorial( 3 ) == 6 );
	assert( factorial( 4 ) == 24 );
	assert( factorial( 5 ) == 120 );
	assert( factorial( 6 ) == 720 );
	return factorial( 7 );
}

Int recursiveTests() {
	assert( recursiveFactorial( 0 ) == 1 );
	assert( recursiveFactorial( 1 ) == 1 );
	assert( recursiveFactorial( 2 ) == 2 );
	assert( recursiveFactorial( 3 ) == 6 );
	assert( recursiveFactorial( 4 ) == 24 );
	assert( recursiveFactorial( 5 ) == 120 );
	assert( recursiveFactorial( 6 ) == 720 );
	return recursiveFactorial( 7 );
}

Int ctimeTests = tests();
Int ctimeRecursiveTests = recursiveTests();

Void main() {
	print( tests() ); //! stdout: 5040
	print( ctimeTests ); //! stdout: 5040
	print( recursiveTests() ); //! stdout: 5040
	print( ctimeRecursiveTests ); //! stdout: 5040
}