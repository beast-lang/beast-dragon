module t_7_ctref;

Void main() {
	// Although @ctime parameters are evaluated at compile time, you can work with them in runtime like with standard variables
	// They would be const for runtime however (after it is implemented)
	@ctime Int i = 3;

	print( i ); //! stdout: 3

	// Now we create a non-compile-time reference and direct it to our compile-time variable i
	// This means that the @ctime variable has (or can have) a memory allocated to it
	Int? ref := i;
	print( ref ); //! stdout: 3

	// And that memory is updated when the @ctime variable changes
	@ctime i = i + 5;
	print( ref ); //! stdout: 8
}