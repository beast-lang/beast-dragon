module t_destructors; //! run

class C {

	Void #ctor() {
		val.#ctor();
		ref.#ctor();
	}
	Void #ctor( Int!? ref, Int val ) {
		this.ref.#ctor( ref );
		this.val.#ctor( val );
	}
	Void #ctor( C? other ) {
		ref.#ctor( other.ref );
		val.#ctor( other.val );
	}
	Void #dtor() {
		ref = ref * 10 + val;
	}

	Int val;
	Int!? ref;

}

Void subtest( Int? ref ) {
	C a = C( ref, 1 );
	assert( ref == 1 );

	C( ref, 2 );
	assert( ref == 12 );

	C c;
	c.ref := ref;
	c.val = 3;

	{
		C c;
		c.ref := ref;
		c.val = 4;
		assert( ref == 12 );
	}
	assert( ref == 124 );
}

Void test() {
	Int val;
	subtest( val );
	assert( val == 12431 );
}

Void main() {
	test();
	@ctime test();
}