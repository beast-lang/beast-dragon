module t_autovars;

auto z = true;
auto nope; //! error: missingInitValue

Void foo( Bool x ) {
	@static Bool staticX;

	foo( staticX );
	foo( z );
}

Void main() {
	Bool x;
	x.#type y = x;
}

Void ok1() {
	auto x = true;
}

Void err1() {
	foo( x ); //! error: unknownIdentifier
	Bool x;
}

Void err2() {
	foo( :x ); //! error: noMatchingOverload
}

Void err3() {
	foo( foo.x ); //! error: unknownIdentifier
}

Void err4() {
	#returnType x; //! error: zeroSizeVariable
}

Void err5() {
	auto x; //! error: missingInitValue
}