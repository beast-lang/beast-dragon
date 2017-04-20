module t_ctimemirroring2; //! run

Void test() {
	@ctime Int! x = 5;
	Int?! ref := x;
	assert( ref == 5 );

	@ctime x = x - 9;
	assert( ref == -4 );

	Int y = 8;
	ref := y;
	assert( ref == 8 );
	assert( x == -4 );
	assert( @ctime x == -4 );

	@ctime x = 12;
	assert( ref == 8 );
	@ctime assert( x == 12 );

	ref := x;
	assert( ref == 12 );
}

Void main() {
	test();
	@ctime test();
}