module t_inc;

Int inc( Int!? x ) {
	x = x + 1;
	return x;
}

Void main() {
	@ctime Int! x = 5;
	@ctime inc( x );
	print( x ); //! stdout: 6
}