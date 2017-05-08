module t_7_returnbpoffset; //! run

class C {

	Void #ctor() {
		data.#ctor();
	}
	Void #ctor( C? other ) {
		data.#ctor( other.data );
	}
	Void #dtor() {
		data.#dtor();
	}

	Int data;

}

Void test() {
	C a;
	{
		C b;
		{
			C c;
			return;
		}
	}
}

Void main() {
	@ctime test();
}