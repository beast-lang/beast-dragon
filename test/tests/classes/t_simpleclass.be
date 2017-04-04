module t_simpleclass; //! run

class C {

	Void #ctor() {
		x.#ctor( #Ctor.opAssign, 6 );
		y.#ctor();
	}
	Void #dtor() {
		x.#dtor();
		y.#dtor();
	}

	Void swap() {
		auto tmp = x;
		x = y;
		y = tmp;
	}

	Int x;
	Int y;
	@static Int z;

}

Bool test() {
	C c;
	assert( c.x == 6 );
	assert( c.y == 0 );

	c.y = c.x * 2 + c.y;
	assert( c.x == 6 );
	assert( c.y == 12 );

	c.swap();
	assert( c.x == 12 );
	assert( c.y == 6 );

	return true;
}

@ctime Bool ctTest = test();

Void main() {
	test();

	C.z = 6;
	print( C.z ); //! stdout: 6
}