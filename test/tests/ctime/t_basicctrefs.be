module t_basicctrefs;

@ctime Int? ctxr := ctx;
@ctime Int ctx = 89;

Bool foo() {
	Bool x;
	x = true;

	Bool? rx := x;
	rx = false;

	return rx;
}

@ctime Bool b = foo();

Void main() {
	assert( !b );

	print( ctxr ); //! stdout: 89
}