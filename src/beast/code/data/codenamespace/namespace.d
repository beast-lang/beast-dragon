module beast.code.data.codenamespace.namespace;

import beast.code.data.toolkit;
import beast.util.identifiable;

abstract class Namespace : Identifiable {

	public:
		this( Identifiable parent ) {
			parent_ = parent;
		}

	public:
		Symbol[ ] members( ) {
			return members_;
		}

		/// If there are any symbols in this namespace with given identifier, returns them in an overloadset.
		Overloadset resolveIdentifier( Identifier id, DataEntity instance ) {
			if ( auto result = id in groupedMembers_ )
				return ( *result ).map!( x => x.dataEntity( instance ) ).array.Overloadset;

			return Overloadset( );
		}

	public:
		final override string identificationString( ) {
			if ( this is null )
				return "#error#";
				
			return parent_.identificationString;
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
		Identifiable parent_;
		Symbol[ ] members_;
		Symbol[ ][ Identifier ] groupedMembers_;

}
