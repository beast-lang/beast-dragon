module t_paramevalorder;
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

	Void func( Int arg1, Int arg2 ) {

	}

	Int data;
}

Void record( Int? i, Int set ) {
	i = i * 10 + set;
}

C mirror( C mirror, Int? i, Int set ) {
	record( i, set );
	return mirror;
}

Int mirror( Int mirror, Int? i, Int set ) {
	record( i, set );
	return mirror;
}

Int test() {
	C c;
	Int i;

	mirror( c, i, 1 ).func( mirror( 1, i, 2 ), mirror( 2, i, 3 ) );
	return i;
}

Void main() {
	print( test() ); //! stdout: 123
	print( @ctime test() ); //! stdout: 123
}