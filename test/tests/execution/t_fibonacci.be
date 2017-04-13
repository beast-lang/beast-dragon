module t_fibonacci;

Int fibonacci( Int n ) {
	if( n <= 0 )
		return 0;

	if( n <= 2 )
		return 1;
	
	Int! a1 = 1;
	Int! a2 = 1;

	Int! i = 2;
	while( i < n ) {
		Int result = a1 + a2;
		a1 = a2;
		a2 = result;
		i = i + 1;
	}

	return a2;
}

Void main() {
	print( @ctime fibonacci( 3 ) ); //! stdout: 2
	print( fibonacci( 4 ) ); //! stdout: 3
	print( @ctime fibonacci( 5 ) ); //! stdout: 5
	print( fibonacci( 6 ) ); //! stdout: 8
	print( @ctime fibonacci( 7 ) ); //! stdout: 13
	print( fibonacci( 8 ) ); //! stdout: 21
}