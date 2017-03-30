module t_stackoverflow;

Bool x() {
	return x(); //! error: ctStackOverflow
}

@ctime Bool b = x();

Void main() {

}