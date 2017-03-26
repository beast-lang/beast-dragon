module t_refbool;

Void main() {
	Bool x;
	Bool y;

	print( x ); //! stdout: "0"
	print( y ); //! stdout: "0"

	Bool? xr := x;
	Bool? yr := y;

	print( xr ); //! stdout: "0"
	print( yr ); //! stdout: "0"

	xr = true;

	print( x ); //! stdout: "1"
	print( y ); //! stdout: "0"
	print( xr ); //! stdout: "1"
	print( yr ); //! stdout: "0"

	xr := yr;

	print( x ); //! stdout: "1"
	print( y ); //! stdout: "0"
	print( xr ); //! stdout: "1"
	print( yr ); //! stdout: "0"

	xr = false;

	print( x ); //! stdout: "1"
	print( y ); //! stdout: "0"
	print( xr ); //! stdout: "1"
	print( yr ); //! stdout: "0"

	xr = true;

	print( x ); //! stdout: "1"
	print( y ); //! stdout: "1"
	print( xr ); //! stdout: "1"
	print( yr ); //! stdout: "1"

	yr = false;

	print( x ); //! stdout: "1"
	print( y ); //! stdout: "0"
	print( xr ); //! stdout: "1"
	print( yr ); //! stdout: "0"

	yr := x;

	print( x ); //! stdout: "1"
	print( y ); //! stdout: "0"
	print( xr ); //! stdout: "1"
	print( yr ); //! stdout: "0"

	yr = false;

	print( x ); //! stdout: "0"
	print( y ); //! stdout: "0"
	print( xr ); //! stdout: "0"
	print( yr ); //! stdout: "0"
}