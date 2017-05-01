module t_conditionalcompilation;

auto test( @ctime Type T ) {
	@ctime if( T == Bool )
		return true;
	else
		return 5;
}

Void main() {
	print( test( Int ) ); //! stdout: 5
	print( test( Bool ) ); //! stdout: 1
	print( test( Int64 ) ); //! stdout: 5
}