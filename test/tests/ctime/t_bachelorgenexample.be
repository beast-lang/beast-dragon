module t_bachelorgenexample;

@ctime Int? valPtr := val;
@ctime Int val = 3 + 5;

Void foo( Int x ) {
	print( x );
}

Void main() {
	@ctime Int! x = 5;
	@ctime Int! y = 6;
	foo( @ctime x + y ); //! stdout: 11

	@ctime Int!? ref := x;
	foo( ref ); //! stdout: 5

	@ctime ref := y;
	foo( ref ); //! stdout: 6

	foo( valPtr ); //! stdout: 8
}