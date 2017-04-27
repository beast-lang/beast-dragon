module t_colonident;

class C {

	Void #ctor() {
		val.#ctor();
	}
	Void #ctor( C? other ) {
		val.#ctor( other.val );
	}
	Void #ctor( Int val ) {
		this.val.#ctor( val );
	}
	Void #dtor() {
		val.#dtor();
	}

	C #opBinary( Operator.binPlus, C other ) {
		C result = val + other.val;
		return result;
	}

	Int! val;

@static @ctime:
	C a = 1;
	C b = 2;
	C c = 3;
	C d = 4;

}

Void test( C c ) {
	print( c.val );
}

Void main() {
	test( :a ); //! stdout: 1
	test( :b ); //! stdout: 2
	test( :d + :d ); //! stdout: 8
}