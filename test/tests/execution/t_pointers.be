module t_pointers;

Void main() {
	Int x = 5;
	Int y = 6;

	// ptr now references variable x
	Pointer ptr = x.#addr;
	print( ptr.data( Int ) ); //! stdout: 5
	ptr.data( Int ) = 10; // x is set to 10
	print( ptr.data( Int ) ); //! stdout: 10

	ptr = y.#addr; // ptr now references variable y
	print( ptr.data( Int ) ); //! stdout: 6
	ptr.data( Int ) = 7; // y is is set to 7
	print( ptr.data( Int ) ); //! stdout: 7
}