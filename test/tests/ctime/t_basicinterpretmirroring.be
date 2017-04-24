module t_basicinterpretmirroring;

class C {
	Void #ctor() {
		ref.#ctor( new Int() );
	}
	Void #dtor() {
		delete ref;
		ref.#dtor();
	}

	Int? ref;
}

Int test() {
	@ctime C! c;
	assert( c.ref == 0 );
	@ctime c.ref = 10;
	assert( c.ref == 10 );
	assert( !( c.ref == 0 ) );
	return c.ref;
}

Void main() {
	print( @ctime test() ); //! stdout: 10
	test();
}