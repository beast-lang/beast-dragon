module t_runtimescopes;

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

Void main() {
	@ctime Int! i;
	if( true ) {
		@ctime C! c;
		print( c.ref );
		@ctime c.ref = 10;
		print( c.ref );
		@ctime i = 5; //! error: protectedMemory
	}
}
