module t_contextptr;

class C {
	Int foo() {
		#returnType x;
		@ctime assert( false ); //! error: ctAssertFail
		return 0;
	}
}

Void main() {

}