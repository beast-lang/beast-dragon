module beast.code.ast.node;

import beast.code.ast.toolkit;
import beast.code.symbol.symbol;

/// Base class for arr abstract syntax tree nodes
abstract class ASTNode {

public:
	/// Location of code corresponding with the AST node
	CodeLocation codeLocation;

public:
	/// All nodes that are direct children of the current node
	final @property ASTNode[ ] subnodes( ) {
		return _subnodes.filter!( x => x !is null ).array.sort!( ( a, b ) { //
			assert( a.codeLocation.source is b.codeLocation.source );
			return a.codeLocation.startPos < b.codeLocation.startPos;
		} ).array;
	}

	@property ASTNode toNode( ) {
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
	@property InputRange!ASTNode _subnodes( ) {
		return inputRangeObject( cast( ASTNode[ ] ) null );
	}

	/**
	Utility function for constructing subnode list.

	Arguments can be:
		* Any class derived from ASTNode
		* Any range with elements derived from ASTNode
	*/
	static InputRange!ASTNode nodeRange( Args... )( auto ref Args args ) {
		return mixin( {
			string[ ] arrayStr, chainStr;
			foreach ( i, Arg; Args ) {
				static if ( is( Arg : ASTNode ) )
					arrayStr ~= "args[%s].toNode".format( i );

				else static if ( isInputRange!Arg && is( ElementType!Arg == ASTNode ) )
					chainStr ~= "args[%s]".format( i );

				else static if ( isInputRange!Arg && is( ElementType!Arg : ASTNode ) )
					chainStr ~= "args[%s].map!( x => x.toNode )".format( i );

				else
					static assert( 0, "Unsupported parameter type: " ~ typeof( arg ).stringof );
			}

			if ( arrayStr.length )
				chainStr ~= "[" ~ arrayStr.join( ", " ) ~ "]";

			if ( !chainStr.length )
				chainStr ~= "cast(ASTNode[]) []";

			return "inputRangeObject( chain(" ~ chainStr.joiner( "," ).to!string ~ ") )";
		}( ) );
	}

private: /// For semantic analysis, it is possible to link symbols to the AST nodes
	/// HOWEVER, this can be accessed after EVERYTHING IS DONE
	Symbol[ ] relatedSymbols_;

}
