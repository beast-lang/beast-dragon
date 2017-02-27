module beast.code.data.entitycontainer.namespace.namespace;

import beast.code.data.toolkit;
import beast.code.data.entitycontainer.container;
import std.functional;

abstract class Namespace : EntityContainer {

public:
	alias InstanceTransformer = DataEntity delegate( DataEntity );
	static __gshared InstanceTransformer defaultInstanceTransformer;
	private enum _init = HookAppInit.hook!( { //
			defaultInstanceTransformer = ( ( DataEntity e ) => cast( DataEntity ) null ).toDelegate;
		} );

public:
	this( Symbol symbol, InstanceTransformer instanceTransformer = defaultInstanceTransformer ) {
		symbol_ = symbol;
		instanceTransformer_ = instanceTransformer;
	}

public:
	final override bool isScope( ) {
		return false;
	}

	final override Namespace asNamespace( ) {
		return this;
	}

	final override DataScope asScope( ) {
		assert( 0 );
	}

public:
	final Namespace parent( ) {
		return parent_;
	}

	void parent( Namespace set ) {
		parent_ = set;
	}

public:
	/// Symbol this namespace belongs to (for in-function control stmts, it is the function the stmt is in)
	final Symbol symbol( ) {
		return symbol_;
	}

	string identificationString( ) {
		return symbol.identificationString;
	}

public:
	/// If there are any symbols in this namespace with given identifier, returns them in an overloadset.
	Overloadset resolveIdentifier( Identifier id, DataEntity instance ) {
		if ( auto result = id in groupedMembers_ )
			return ( *result ).map!( x => x.data( instance ) ).array.Overloadset;

		return Overloadset( );
	}

	Overloadset resolveIdentifierRecursively( Identifier id, DataEntity instance ) {
		if ( auto result = resolveIdentifier( id, instance ) )
			return result;

		if ( parent_ ) {
			if ( auto result = parent_.resolveIdentifierRecursively( id, instanceTransformer_( instance ) ) )
				return result;
		}

		return Overloadset( );
	}

public:
	final void initialize( Symbol[ ] symbolList ) {
		members_ = symbolList;

		// Construct overloadset
		foreach ( sym; symbolList ) {
			assert( sym.identifier );
			assert( !sym.parent );

			sym.parent = this;

			if ( auto ptr = sym.identifier in groupedMembers_ )
				*ptr ~= sym;
			else
				groupedMembers_[ sym.identifier ] = [ sym ];
		}
	}

private:
	Symbol symbol_;
	Namespace parent_;
	InstanceTransformer instanceTransformer_;

private:
	Symbol[ ] members_;
	Symbol[ ][ Identifier ] groupedMembers_;

}
