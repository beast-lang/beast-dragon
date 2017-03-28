module beast.code.ast.expr.binary;

import beast.code.ast.toolkit;

DataEntity resolveBinaryOperation( AST_Node ast, DataEntity left, AST_Expression rightExpr, DataEntity binXX, DataEntity binXXR, Token.Operator op ) {
	import std.range : chain;

	// First we try left.#operator( binXX, rightExpr )
	CallMatchSet leftCall = left.tryResolveIdentifier( ID!"#operator" ).CallMatchSet( ast, false ).arg( binXX ).arg( rightExpr );
	if ( auto result = leftCall.finish( ) )
		return result;

	// If looking for left.#operator( binXX, rightExpr ) failed, we build right side and try right.#operator( binXXR, left )
	DataEntity right = rightExpr.buildSemanticTree( null, false ).single;

	benforce( right !is null, E.cannotResolve, "Cannot resolve %s %s %s:%s".format(  //
			left.dataType.identificationString, Token.operatorStr[ op ], right.dataType.identificationString, //
			leftCall.matches.map!( x => "\n\n\t%s:\n\t\t%s".format( x.sourceDataEntity.tryGetIdentificationString, x.errorStr ) ).joiner //
	 ) );

	CallMatchSet rightCall = right.tryResolveIdentifier( ID!"#operator" ).CallMatchSet( ast, false ).arg( binXXR ).arg( left );
	if ( auto result = rightCall.finish() )
		return result;

	berror( E.cannotResolve, "Cannot resolve %s %s %s:%s".format(  //
			left.dataType.identificationString, Token.operatorStr[ op ], right.dataType.identificationString, //
			chain( leftCall.matches, rightCall.matches ).map!( x => "\n\n\t%s:\n\t\t%s".format( x.sourceDataEntity.tryGetIdentificationString, x.errorStr ) ).joiner //
	 ) );
	assert( 0 );
}
