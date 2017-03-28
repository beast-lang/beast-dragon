module t_basicctrefs;

Bool foo() {
	Bool x;

	x = true;

	Bool? rx := x;

	rx = false;

	return rx;
}

Bool b = foo();

Void main() {
	assert( !b );
}