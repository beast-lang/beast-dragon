module t_2_factorial;

Void main() {
	// You don't have to have declarations before usage (factorial can be declared later)
	print( factorial( 5 ) ); //! stdout: 120

	// By adding @ctime to an expression, you execute the expression at compile time
	print( @ctime factorial( 5 ) ); //! stdout: 120
}

Int factorial( Int! n ) {
	// The ! in "Int!" marks the variable as mutable (variables are const-by-default)
	// Constness is actually not implemented yet, so ! does nothing and everything is mutable for now
	Int! i = n;
	Int! result = 1;

	while( i > 1 ) {
		// No *=, ++, etc, sorry
		result = result * i;
		i = i - 1;
	}

	return result;
}