module t_int3264symmetrical;

Void main() {
	Int64 x = 8;
	Int32 y = 6;

	print( y == x ); //! stdout: 0	
	print( x == y ); //! stdout: 0	

	print( x + y ); //! stdout: 14
	print( y + x ); //! stdout: 14

	print( x * y ); //! stdout: 48
	print( y * x ); //! stdout: 48

	print( x - y ); //! stdout: 2
	print( y - x ); //! stdout: -2

	print( x / y ); //! stdout: 1
	print( y / x ); //! stdout: 0
}
