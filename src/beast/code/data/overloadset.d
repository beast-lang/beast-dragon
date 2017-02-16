module beast.code.data.overloadset;

import beast.code.data.toolkit;

struct Overloadset {

public:
	DataEntity[ ] data;

public:
	/// Returns list of decorators in the overloadset
	Symbol_Decorator[ ] filter_decoratorsOnly( ) {
		assert( 0 );
		// TODO:
	}

public:
	/// Returns single entry from the overloadset
	/// If the overloadset is empty, throws noMatchingOverload error, if it contains multiple items, throws ambiguousResolution error
	DataEntity single( ) {
		benforce( data.length < 2, E.ambiguousResolution, "Expression is ambigous: can be '%s' or '%s' (or possibly more)".format( data[ 0 ], data[ 1 ] ) );
		benforce( data.length > 0, E.noMatchingOverload, "Empty overloadset (more explaining message should have been shown, this would probably deserve a bug report)" );
		return data[ 0 ];
	}

	/// Returns single entry from the overloadset that is of expected type or implicitly converible to to it
	/// Throws error if no matching overload is found (or the result is ambiguous)
	/// The expectedType can be null, in that case, the "single"" function is called
	DataEntity single_expectType( Symbol_Type expectedType ) {
		if ( !expectedType )
			return this.single( );

		/// TODO: Implicit cast check
		DataEntity result;

		foreach ( item; data ) {
			if ( item.dataType !is expectedType )
				continue;

			benforce( result is null, E.ambiguousResolution, "Expression is ambigous: can be '%s' or '%s' (or possibly more)".format( result, item ) );
			result = item;
		}

		benforce( result !is null, E.noMatchingOverload, "Empty overloadset (more explaining message should have been shown, this would probably deserve a bug report)" );
		return result;
	}

public:
	bool opCast( T : bool )( ) const {
		return data.length > 0;
	}

}
