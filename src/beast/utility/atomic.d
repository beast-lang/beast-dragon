module beast.utility.atomic;

public import core.atomic;

/// Ors the data with the orMask and returns its previous value
ubyte atomicFetchThenOr( T )( shared ref T data, T orMask ) {
	T get, set;
	do {
		get = set = atomicLoad!( MemoryOrder.raw )( data );
		set |= orMask;
	}
	while ( !cas( &data, get, set ) );
	return get;
}