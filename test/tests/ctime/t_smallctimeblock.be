module t_smallctimeblock;

Void main() {
	@ctime Type! T = Int;

	T x = 5;
	print( x );

	@ctime {
		Type! T2 = Int;

		if( T2.#instanceSize == 4 )
			T2 = Bool;

		T = T2;
	}

	T y = true;
	print( y );
}