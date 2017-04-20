module t_simpleif; //! run

Bool test() {
	if( false ) {
		assert( false );
	} else
		assert( true );

	return true;
}

Bool x = test();

Void main() {
	if( x )
		print( x );
	else
		assert( false );
}