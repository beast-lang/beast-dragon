module beast.utility.hooks;

template Hook( string hookName, Args... ) {

public:
	alias Function = void function( Args );

	template hook( Function func ) {
		shared static this( ) {
			functionList ~= func;
		}

		enum hook = func.stringof;
	}

	void call( Args args ) {
		foreach ( func; functionList )
			func( args );
	}

private:
	__gshared Function[ ] functionList;

}
