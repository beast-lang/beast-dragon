module t_paramevalorder; //! run
// In this test, we test order of evaulation of parameters

class C {
	Void #ctor() {
		data.#ctor();
	}
	Void #dtor() {
		data.#dtor();
	}
	Void #ctor( C? other ) {
		data.#ctor( other.data );
	}

	Void function( Int arg1, Int arg2 ) {

	}

	Int data;
}

Void func( Int? i, Int set ) {
	i = i * 10 + set;
}

C mirror( C mirror, Int? i, Int set ) {
	func( i, set );
	return mirror;
}

Int mirror( Int mirror, Int? i, Int set ) {
	func( i, set );
	return mirror;
}

Bool test() {
	C c;
	Int i;

	mirror( c, i, 1 ).function( mirror( 1, i, 2 ), mirror( 2, i, 3 ) );
	assert( i == 123 );

	return true;
}

Void main() {
	// Runtime test
	test();
}

@ctime Bool ctimeTest = test();