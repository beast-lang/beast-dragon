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

Bool printTrue() {
	print( true );
	return true;
}

Bool printFalse() {
	print( false );
	return false;
}

Void reprint( Bool b ) {
	print( b );
}

@ctime Bool x = and( true, false );
@ctime Bool z = foo();

Void main() {
	print( x ); //! stdout: "0"

	@static Bool y = or( false, true );
	print( y ); //! stdout: "1"

	Bool a = x || y || x;
	print( a ); //! stdout: "1"

	print( z ); //! stdout: "0"

	reprint( true ); //! stdout: "1"
	reprint( false ); //! stdout: "0"

	// Now we test execution order
	print( printTrue() && printFalse() ); //! stdout: "100"
	print( printTrue() && printTrue() ); //! stdout: "111"
	print( printTrue() || printTrue() ); //! stdout: "11"
	print( printFalse() || printTrue() ); //! stdout: "011"
	print( printFalse() && printTrue() ); //! stdout: "00"
}