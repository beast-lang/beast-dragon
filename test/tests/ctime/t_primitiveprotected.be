module t_primitiveprotected;

@ctime Int x;

Void main() {
	x = 5; //! error: protectedMemory
}