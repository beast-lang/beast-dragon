module t_smartparams;

Void foo( Int x, x.#type y ) {
	@ctime assert( x.#type == Int );
	@ctime assert( y.#type == Int );
	@ctime assert( false ); //! error: ctAssertFail
}

y.#type foo2( Int x, Bool y ) {
	@ctime assert( x.#type == Int );
	@ctime assert( y.#type == Bool );
	@ctime assert( #returnType == Bool );
	@ctime assert( false ); //! error: ctAssertFail
}

Void main() {

}

#returnType err1() { //! error: dependencyLoop

}

Int err2( #returnType x ) { //! error: dependencyLoop

}

Void err3( y.#type x, Int y ) { //! error: unknownIdentifier

}