module t_1_ctimemirroring;

Void test() {
	@ctime Int! i = 4;

	assert( i == 4 );

	@ctime i = 5;
	@ctime i = i + 1;

	assert( i == 6 );
}

Void main() {
	@ctime Int! i = 4;

	print( i ); //! stdout: 4

	@ctime Int! c = 8;
	print( c ); //! stdout: 8

	@ctime i = 5;
	@ctime i = i + 1;

	print( i ); //! stdout: 6

	print( c + i ); //! stdout: 14

	@ctime c = i;
	print( c * i ); //! stdout: 36

	@ctime test();
}
