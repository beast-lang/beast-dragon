module beast.code.ast.node;

import beast.code.ast.toolkit;
import beast.code.sym.symbol;

/// Base class for arr abstract syntax tree nodes
abstract class AST_Node {

public:
	/// Location of code corresponding with the AST node
	CodeLocation codeLocation;

public:
	/// All nodes that are direct children of the current node
	final @property AST_Node[ ] subnodes( ) {
		return _subnodes.filter!( x => x !is null ).array.sort!( ( a, b ) { //
			assert( a.codeLocation.source is b.codeLocation.source );
			return a.codeLocation.startPos < b.codeLocation.startPos;
		} ).array;
	}

	@property AST_Node toNode( ) {
		return this;
	}

public:
	/// Marks a symbol as related to this AST node (used in intellisense)
	final void relateWithSymbol( Symbol symbol ) {
		synchronized ( this )
			relatedSymbols_ ~= symbol;
	}

protected:
	/// This function should return all subnodes of given AST node. It can contain null elements.
	@property InputRange!AST_Node _subnodes( ) {
		return inputRangeObject( cast( AST_Node[ ] ) null );
	}

	/**
	Utility function for constructing subnode list.

	Arguments can be:
		* Any class derived from AST_Node
		* Any range with elements derived from AST_Node
	*/
	static InputRange!AST_Node nodeRange( Args... )( auto ref Args args ) {
		return mixin( {
			string[ ] arrayStr, chainStr;
			foreach ( i, Arg; Args ) {
				static if ( is( Arg : AST_Node ) )
					arrayStr ~= "args[%s].toNode".format( i );

				else static if ( isInputRange!Arg && is( ElementType!Arg == AST_Node ) )
					chainStr ~= "args[%s]".format( i );

				else static if ( isInputRange!Arg && is( ElementType!Arg : AST_Node ) )
					chainStr ~= "args[%s].map!( x => x.toNode )".format( i );

				else
					static assert( 0, "Unsupported parameter type: " ~ typeof( arg ).stringof );
			}

			if ( arrayStr.length )
				chainStr ~= "[" ~ arrayStr.join( ", " ) ~ "]";

			if ( !chainStr.length )
				chainStr ~= "cast(AST_Node[]) []";

			return "inputRangeObject( chain(" ~ chainStr.joiner( "," ).to!string ~ ") )";
		}( ) );
	}

private: /// For semantic analysis, it is possible to link symbols to the AST nodes
	/// HOWEVER, this can be accessed after EVERYTHING IS DONE
	Symbol[ ] relatedSymbols_;

}
