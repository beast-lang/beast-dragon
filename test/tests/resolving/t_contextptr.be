module t_contextptr;

class C {
	Int foo() {
		#returnType x;
		@ctime assert( 0 ); //! error: ctAssertFail
		return 0;
	}
}

Void main() {

}