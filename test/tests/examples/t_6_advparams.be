module t_6_advparams;

// A function can have "auto" return type -> return type is then deduced from the first return in its code
// "auto" parameter deduces its type
auto printAuto( auto x ) {
	print( x.#instanceSize );
	print( x );
}

// You can use data of previous parameters in further parameters
// Return type can work with any parameter
a.#type max( auto a, a.#type b ) {
	if( a > b )
		return a;
	else
		return b;
}

Void main() {
	printAuto( true ); //! stdout: 1; stdout: 1
	printAuto( 8 ); //! stdout: 4; stdout: 8

	print( max( 1, 5 ) ); //! stdout: 5
	print( max( 5, 1 ) ); //! stdout: 5
	print( max( 15, 15 ) ); //! stdout: 15
}