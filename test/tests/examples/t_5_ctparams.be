module t_5_ctparams;

// A function can have @ctime parameters whose value is evaluated at compile time
Void printInstanceSize( @ctime Type T, Int add ) {
	print( T.#instanceSize + add );
}

Void main() {
	// Ctime parameters are passed just like standard ones
	printInstanceSize( Bool, 0 ); //! stdout: 1
	printInstanceSize( Int, 1 ); //! stdout: 5
	printInstanceSize( Int64, 2 ); //! stdout: 10
}