module t_localvarusage;

Void foo1( Bool x ) {

}

Void foo2( Bool x, Bool y ) {
	foo1( x );
	foo1( y );
}

Void main() {
	foo2( true, false );
}