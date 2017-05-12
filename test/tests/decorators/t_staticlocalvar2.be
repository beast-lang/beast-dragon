module t_staticlocalvar2;

Void foo() {
	@static Int! x = 4;
	print( x );
	x = x + 1;
}

Void main() {
	foo(); //! stdout: 4
	foo(); //! stdout: 5
}