module t_basicmirroring;

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
	@ctime C! c;
	print( c.ref ); //! stdout: 0
	@ctime c.ref = 10;
	print( c.ref ); //! stdout: 10
}
