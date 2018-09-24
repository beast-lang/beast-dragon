module t_9_ctcmpexecorder; //! run

Bool test(Int? val, Int inc, Bool result) {
	val = val * 10 + inc;
	return result;
}

Void main() {
	@ctime {
		Int val = 0;
		Bool b = test(val, 1, true) == test(val, 2, true) == test(val, 3, true);
	}
	print(val); //! stdout: 123
	
	if(b)
		print(99); //! stdout: 99
}