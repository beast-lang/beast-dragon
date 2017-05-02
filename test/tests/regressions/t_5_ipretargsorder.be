module t_5_ipretargsorder;

// Before the bugfix, interpreter was putting arguments in the wrong order on the stack

Void foo( Int? xref, Int? yref, Int x, Int y ) {
	xref = x;
	yref = y;
}

Int inc( Int? i ) {
	i = i + 1;
	return i;
}

Void main() {
	@ctime Int i;
	@ctime Int xr;
	@ctime Int yr;
	@ctime foo( xr, yr, i, inc( i ) );
	print( xr ); //! stdout: 0
	print( yr ); //! stdout: 1
}