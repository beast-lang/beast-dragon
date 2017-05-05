module t_ctimeauto;

Void foo1( auto x ) {
	print( x );
}

Void foo2( @ctime auto x ) {
	print( x );
}

Void main() {
	foo1( 5 ); //! stdout: 5
	foo1( true ); //! stdout: 1

	foo2( 10 ); //! stdout: 10
	foo2( false ); //! stdout: 0
}