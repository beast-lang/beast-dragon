module t_newautoerrs;

Void main() {

}

Void err1() {
	auto i = new auto(); //! error: cannotInfer
}

Void err2() {
	Int i = new auto(); //! error: referenceTypeRequired
}