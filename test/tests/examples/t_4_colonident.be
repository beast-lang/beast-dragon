module t_4_colonident;

// Class mechanics is similar to C++ (no inheritance yet)
class Number {
	// No public/private so far

	// Implicit constructor
	Void #ctor() {
		// Auto member constructor calling is not generated yet, so you have to do it manually
		data.#ctor();
	}

	// Copy constructor
	Void #ctor( Number? other ) {
		data.#ctor( other.data );
	}

	// Init-by-value constructor
	Void #ctor( Int value ) {
		data.#ctor( value );
	}

	// Destructor
	Void #dtor() {
		data.#dtor();
	}

	Int! data;

	// There are no enums so far, but this is quite equivalent to them
	@static @ctime:
		Number one = 1;
		Number two = 2;
		Number three = 3;
		Number four = 4;

}

Void foo( Number n ) {
	print( n.data );
}

Void foo2( Number n ) {
	print( n.data );
}

// Operator is a Beast-defined enum containing members like binPlus, binMinus, preNot etc
Void foo2( Operator o ) {
	print( o.to( Int32 ) );
}

Void main() {
	// foo expects parameter of type Number
	// Using the :ident syntax construct, we look for "one" in the expected parameter type (which is Number)
	foo( :one ); //! stdout: 1

	// The :ident syntax also works with overloads
	foo2( :one ); //! stdout: 1
	foo2( :binPlus ); //! stdout: 2
}