module t_8_cmpcallorder;

auto test(Int x, auto result) {
	print(x);
	return result;
}

Void main() {
	print(test(2, true) == test(3, true) == test(4, true)); //! stdout: 2341
	print(test(2, true) == test(3, true) == test(4, false)); //! stdout: 2340
	print(test(2, true) == test(3, false) == test(4, true)); //! stdout: 230
}