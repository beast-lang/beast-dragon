module t_ctwriteinrtcode;

Int inc( Int!? x ) {
	x = x + 1; //! error: protectedMemory
	return x;
}

Void main() {
	@ctime Int! x = 5;
	print( @ctime inc( x ) );
}