module t_staticcall;

Void main() {

}

Void err1() {
	Int x;
	x? y; //! error: noMatchingOverload
}

Void err2() {
	Int x;
	x! y; //! error: noMatchingOverload
}