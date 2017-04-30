module t_3_fibonacci;

Void main() {
	// You can have @ctime variables that are evaluated at compile time
	@ctime Int! ctimeVariable = 0;

	print( ctimeVariable ); //! stdout: 0

	// You can change @ctime variables value
	@ctime ctimeVariable = fibonacci( 10 );
	
	print( ctimeVariable ); //! stdout: 55
}

Int fibonacci( Int n ) {
	if( n <= 0 )
		return 0;

	if( n <= 2 )
		return 1;
	
	Int! a1 = 1;
	Int! a2 = 1;

	Int! i = 2;
	// No for statements so far
	while( i < n ) {
		Int result = a1 + a2;
		a1 = a2;
		a2 = result;
		i = i + 1;
	}

	return a2;
}