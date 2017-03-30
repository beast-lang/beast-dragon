module t_assertfail;

Bool err1() {
	assert( false ); //! error: ctAssertFail
	return false;
}

@ctime Bool a = err1();

Bool err2() { //! error: noReturnExit

}

@ctime Bool b = err2();

Void main() {

}