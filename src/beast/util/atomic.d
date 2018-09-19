module beast.util.atomic;

import core.atomic : atomicLoad, MemoryOrder, cas;

/// Ors the data with the orMask and returns its previous value
ubyte atomicFetchThenOr(T)(shared ref T data, T orMask) {
	T get, set;
	do {
		get = set = atomicLoad!(MemoryOrder.raw)(data);
		set |= orMask;
	}
	while (!cas(&data, get, set));
	return get;
}
