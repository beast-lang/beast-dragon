module t_deleteerrors;

Void main() {

}

Void err1() {
	Int x;
	delete x; //! error: referenceTypeRequired
}