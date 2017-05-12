module t_ctimeif;

Int x = 5;

Void foo( @ctime Type T ) {	
	@ctime if( T == Int )
		x = x + 1;
		
	print( x );
	x = x + 1;
}

Void main() {
	foo( Bool ); //! stdout: 5
	foo( Int ); //! stdout: 7
	foo( Type ); //! stdout: 8
}