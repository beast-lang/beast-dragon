module beast.code.ast.expr.binary;

import beast.code.ast.toolkit;
import beast.code.data.symbol;
import beast.code.data.matchlevel;

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
	if ( auto result = rightCall.finish( ) )
		return result;

	berror( E.cannotResolve, "Cannot resolve %s %s %s:\n%s%s\n%s%s".format(  //
			left.dataType.identificationString, Token.operatorStr[ op ], right.dataType.identificationString, //
			binXX.valueIdentificationString, leftCall.matches.map!( x => "\n\t%s:\n\t\t%s\n".format( x.sourceDataEntity.identificationString, x.errorStr ) ).joiner, //
			binXXR.valueIdentificationString, rightCall.matches.map!( x => "\n\t%s:\n\t\t%s\n".format( x.sourceDataEntity.identificationString, x.errorStr ) ).joiner ) //
	 );
	assert( 0 );
}

DataEntity resolveBinaryOperation( AST_Node ast, DataEntity left, DataEntity right, DataEntity binXX, DataEntity binXXR, Token.Operator op ) {
	import std.range : chain;

	// First we try left.#operator( binXX, rightExpr )
	CallMatchSet leftCall = left.tryResolveIdentifier( ID!"#operator" ).CallMatchSet( ast, false ).arg( binXX ).arg( right );
	if ( auto result = leftCall.finish( ) )
		return result;

	CallMatchSet rightCall = right.tryResolveIdentifier( ID!"#operator" ).CallMatchSet( ast, false ).arg( binXXR ).arg( left );
	if ( auto result = rightCall.finish( ) )
		return result;

	berror( E.cannotResolve, "Cannot resolve %s %s %s:\n%s%s\n%s%s".format(  //
			left.dataType.identificationString, Token.operatorStr[ op ], right.dataType.identificationString, //
			binXX.valueIdentificationString, leftCall.matches.map!( x => "\n\t%s:\n\t\t%s\n".format( x.sourceDataEntity.identificationString, x.errorStr ) ).joiner, //
			binXXR.valueIdentificationString, rightCall.matches.map!( x => "\n\t%s:\n\t\t%s\n".format( x.sourceDataEntity.identificationString, x.errorStr ) ).joiner ) //
	 );
	assert( 0 );
}

/// Prepares binary operation resolution, but you can afterwards provide different operands (of the same type tho)
DataEntity delegate( DataEntity, DataEntity ) prepareResolveBinaryOperation( AST_Node ast, DataEntity left, DataEntity right, DataEntity binXX, DataEntity binXXR, Token.Operator op ) {
	import std.range : chain;

	// First we try left.#operator( binXX, rightExpr )
	CallMatchSet leftCall = left.tryResolveIdentifier( ID!"#operator" ).CallMatchSet( ast, false ).arg( binXX ).arg( right );
	if ( auto result = leftCall.finish_getMatch( ) ) {
		Symbol sym = result.sourceDataEntity.symbol;
		assert( sym );
		return ( l, r ) => sym.dataEntity( MatchLevel.fullMatch, l ).startCallMatch( ast, true, MatchLevel.fullMatch ).arg( binXX ).arg( r ).finish( ).toDataEntity( );
	}

	CallMatchSet rightCall = right.tryResolveIdentifier( ID!"#operator" ).CallMatchSet( ast, false ).arg( binXXR ).arg( left );
	if ( auto result = rightCall.finish_getMatch( ) ) {
		Symbol sym = result.sourceDataEntity.symbol;
		assert( sym );
		return ( l, r ) => sym.dataEntity( MatchLevel.fullMatch, r ).startCallMatch( ast, true, MatchLevel.fullMatch ).arg( binXXR ).arg( l ).finish( ).toDataEntity( );
	}

	berror( E.cannotResolve, "Cannot resolve %s %s %s:\n%s%s\n%s%s".format(  //
			left.dataType.identificationString, Token.operatorStr[ op ], right.dataType.identificationString, //
			binXX.valueIdentificationString, leftCall.matches.map!( x => "\n\t%s:\n\t\t%s\n".format( x.sourceDataEntity.identificationString, x.errorStr ) ).joiner, //
			binXXR.valueIdentificationString, rightCall.matches.map!( x => "\n\t%s:\n\t\t%s\n".format( x.sourceDataEntity.identificationString, x.errorStr ) ).joiner ) //
	 );
	assert( 0 );
}
