module t_returns;

Void main() {

}

Void ok1() {

}

Bool ok2() {
	return false;
}

Bool x;

Bool ok3( Bool y ) {
	return x || y;
}

auto ok4() {
	return true;
	return false;
}

ok1.#returnType ok5() {
	return;	
}

ok2.#returnType ok6() {
	return true;
}

auto ok7() {
	return ok6();
}

auto ok8() {
	return;

	return;
}

auto ok9() {
	return true;
}

ok6.#returnType ok10() {
	return ok6();
}

Void err1() {
	return false; //! error: noMatchingOverload
}

auto err2() {
	return true;
	return; //! error: missingReturnExpression
}

Bool err3() {
	return; //! error: missingReturnExpression
}

auto err4() {
	#returnType x; //! error: dependencyLoop
	return x;
}

auto err5() { //! error: dependencyLoop, lineSpan: 6
	return err6();
}
auto err6() {
	return err5();
}

auto err7() { //! error: dependencyLoop, lineSpan: 9
	return err8();
}
auto err8() {
	return err9();
}
auto err9() {
	return err7();
}