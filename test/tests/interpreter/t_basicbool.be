module t_basicbool;

Bool and( Bool x, Bool y ) {
	return x && y;
}

Bool or( Bool x, Bool y ) {
	return x || y;
}

Bool foo() {
	return and( true, true ) && or( false, true && false );
}

// Static variable value should be executed at ctime (for now)
Bool x = and( true, false );
Bool z = foo();

Void main() {
	print( x ); //! stdout: "0"

	@static Bool y = or( false, true );
	print( y ); //! stdout: "1"

	Bool a = x || y || x;
	print( a ); //! stdout: "1"

	print( z ); //! stdout: "0"
}