module t_dependencyloop;

boo.#type boo; //! error: dependencyLoop

Bool foo;
foo.#type x;

Void func( Bool b ) {}

Void main() {
	func( x );
}

Void err1() {
	xx; //! error: unknownIdentifier
}

Void err2() {
	func( boo ); // This should throw a silent error
	asdgfh; // So no error here should happen
}