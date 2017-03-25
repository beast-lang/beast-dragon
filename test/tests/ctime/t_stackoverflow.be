module t_stackoverflow;

Bool x() {
	return x(); //! error: ctStackOverflow
}

Bool b = x();

Void main() {

}