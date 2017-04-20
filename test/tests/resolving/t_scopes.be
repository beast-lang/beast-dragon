module t_scopes;

Void main() {

}

Void err1() {
	if( true )
		Int a = 6;

	a = a + 1; //! error: unknownIdentifier
}

Void err2() {
	while( false )
		Int a = 6;

	a = a + 1; //! error: unknownIdentifier
}

Void err3() {
	{
		Int a = 6;
	}

	a = a + 1; //! error: unknownIdentifier
}