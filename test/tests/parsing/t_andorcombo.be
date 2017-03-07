//! onlyParsing

module t_andorcombo;

Void main() {
	true || true || true;
	false && false && true;
	true || false && false; //! error: invalidOpCombination
}