module t_malloc;

Int? test() {
	Pointer ptr = malloc( Int.#instanceSize );
	Int? ref = ptr.to( Int? );
	ref.#refData.#ctor( #Ctor.assign, 12 );
	return ref;
}

@ctime auto cttest = test();

Void main() {
	Int? t = test();
	print( t ); //! stdout: 12
	print( cttest ); //! stdout: 12
}