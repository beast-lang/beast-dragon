module t_cmpfail1;

Void main() {
	Int x;
	x > 5 > 6 >= 7 == 8 >= 9;
	1 <= x < 3 == 5 < 7 < 9;
	x != 5;
}

Void err1() {
	Int x;
	x > 6 < 5; //! error: invalidOpCombination
}