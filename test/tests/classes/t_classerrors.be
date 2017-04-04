module t_classerrors;

class C {
	C x; //! error: dependencyLoop
}

Int abc;

class C2 {
	Void #ctor() {
		x.#ctor();
	}
	Void #dtor() {
		x.#dtor();
	}

	Int x;
	@static Int y;

	@static Void foo() {
		x = 5; //! error: needThis
	}
	@static Void foo2() {
		abc = 5;
	}
}

Void main() {
	C2.y = 12;
	C2 c2;
	c2.y = 12;

	C2.x.#type a = 5;
	C2.foo2();
}

Void err1() {
	C2.x = 6; //! error: needThis
}