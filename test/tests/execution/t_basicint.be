module t_basicint;

Void main() {
	Int x = 3;
	print( x ); //! stdout: "3"

	x = x + 5;
	print( x ); //! stdout: "8"

	x = x - 15;
	print( x ); //! stdout: "-7"

	Int? xr := x;
	xr = 936;
	print( x ); //! stdout: "936"

	x = 5 + 5 - 5 + 5 - 5;
	print( x ); //! stdout: "5"

	x = xr * 6;
	print( x ); //! stdout: "30"

	x = x / 10;
	print( x ); //! stdout: "3"
}