module t_classonstack;

class C {
	Void #ctor() {
		a.#ctor();
		b.#ctor();
	}
	Void #ctor( C? other ) {
		a.#ctor( other.a );
		b.#ctor( other.b );
	}
	
	Void #dtor() {
		a.#dtor();
		b.#dtor();
	}

	Int! a;
	Int! b;
}

C test() {
	C c;
	C d;

	assert( c.a == 0 );
	assert( c.b == 0 );
	assert( d.a == 0 );
	assert( d.b == 0 );

	c.a = 145;

	assert( c.a == 145 );
	assert( c.b == 0 );
	assert( d.a == 0 );
	assert( d.b == 0 );

	d.b = c.a + d.a + 50;

	assert( c.a == 145 );
	assert( c.b == 0 );
	assert( d.a == 0 );
	assert( d.b == 195 );

	d.a = c.a - 5;

	assert( c.a == 145 );
	assert( c.b == 0 );
	assert( d.a == 140 );
	assert( d.b == 195 );

	c.b = d.a / 5;

	assert( c.a == 145 );
	assert( c.b == 28 );
	assert( d.a == 140 );
	assert( d.b == 195 );

	return c;
}

Void main() {
	print( @ctime test().a ); //! stdout: 145
	print( ( @ctime test() ).b ); //! stdout: 28
	print( test().a ); //! stdout: 145
}