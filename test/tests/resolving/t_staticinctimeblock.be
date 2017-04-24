module t_staticinctimeblock;

Void main() {
	@ctime Int! y;

	@ctime {
		@static Int x = 5;
		y = x;
		y = y + 6;
	}

	print( y );
}