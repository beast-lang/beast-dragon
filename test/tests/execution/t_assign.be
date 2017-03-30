module t_assign;

Void main() {
	Bool x = true;
	print( x ); //! stdout: 1

	x = false;
	print( x ); //! stdout: 0

	x = x || false;
	print( x ); //! stdout: 0

	x = x || true;
	print( x ); //! stdout: 1

	x = x && true;
	print( x ); //! stdout: 1

	x = x && false;
	print( x ); //! stdout: 0
}