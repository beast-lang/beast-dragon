module t_basiccmp;

Int num4() {
	print( 4 );
	return 4;
}

Int num5() {
	print( 5 );
	return 5;
}

Int num6() {
	print( 6 );
	return 6;
}

Void main() {
	Int x = 5;
	print( x == num5() == num6() ); //! stdout: 560

	x = 6;
	print( x == num5() == num6() ); //! stdout: 50

	x = 4;
	print( x == num4() == num4() ); //! stdout: 441

	print( x != 4 ); //! stdout: 0
	print( x != num5() ); //! stdout: 51
	print( x != num5() + num6() ); //! stdout: 561
}