module beast.code.data.codenamespace.namespace;

import beast.code.data.toolkit;
import std.functional;

abstract class Namespace {

public:
	/// If there are any symbols in this namespace with given identifier, returns them in an overloadset.
	Overloadset resolveIdentifier( Identifier id, DataEntity instance ) {
		if ( auto result = id in groupedMembers_ )
			return ( *result ).map!( x => x.dataEntity( instance ) ).array.Overloadset;

		return Overloadset( );
	}

protected:
	final void initialize_( Symbol[ ] symbolList ) {
		members_ = symbolList;

		// Construct overloadset
		foreach ( sym; symbolList ) {
			assert( sym.identifier );

			if ( auto ptr = sym.identifier in groupedMembers_ )
				*ptr ~= sym;
			else
				groupedMembers_[ sym.identifier ] = [ sym ];
		}
	}

private:
	Symbol[ ] members_;
	Symbol[ ][ Identifier ] groupedMembers_;

}
