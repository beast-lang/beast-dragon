module beast.util.decorator;

/// Helper class for declaring custom decorators (UDA)
struct Decorator(string cookie, Data...) {
	Data data;
	alias data this;
}
