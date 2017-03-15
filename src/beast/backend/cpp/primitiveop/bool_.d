module beast.backend.cpp.primitiveop.bool_;

import beast.backend.cpp.primitiveop.toolkit;

void primitiveOp_boolCtor( DataScope scope_, CodeBuilder_Cpp cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		inst.buildCode( cb, scope_ );
		codeResult_.formattedWrite( "%s*( (bool*) %s ) = false;\n", tabs, codeResult_ );
	}
}

void primitiveOp_boolCopyCtor( DataScope scope_, CodeBuilder_Cpp cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		args[ 1 ].buildCode( cb, scope_ );
		string arg1 = resultVarName_;

		inst.buildCode( cb, scope_ );
		codeResult_.formattedWrite( "%s*( (bool*) %s ) = *( (bool*) %s );\n", tabs, resultVarName_, arg1 );
	}
}

void primitiveOp_boolOr( DataScope scope_, CodeBuilder_Cpp cb, DataEntity inst, DataEntity[ ] args ) { 
	with ( cb ) {
		const string result = resultVarName_;

		inst.buildCode( cb, scope_ );
		codeResult_.formattedWrite( "%sif( *( (bool*) %s ) )\n%s*( (bool*) %s ) = true;\n%selse {\n", tabs, resultVarName_, tabs( 1 ), result, tabs );
		pushScope( );

		args[ 1 ].buildCode( cb, scope_ );
		codeResult_.formattedWrite( "%s*( (bool*) %s ) = *( (bool*) %s );\n", tabs, result, resultVarName_ );

		popScope( );
		codeResult_.formattedWrite( "%s}\n", tabs );

		resultVarName_ = result;
	}
}

void primitiveOp_boolAnd( DataScope scope_, CodeBuilder_Cpp cb, DataEntity inst, DataEntity[ ] args ) {
	with ( cb ) {
		const string result = resultVarName_;

		inst.buildCode( cb, scope_ );
		codeResult_.formattedWrite( "%sif( *( (bool*) %s ) ) {\n", tabs, resultVarName_, tabs( 1 ), result, tabs );
		pushScope( );

		args[ 1 ].buildCode( cb, scope_ );
		codeResult_.formattedWrite( "%s*( (bool*) %s ) = *( (bool*) %s );\n", tabs, result, resultVarName_ );

		popScope( );
		codeResult_.formattedWrite( "%s} else\n%s*( (bool*) %s ) = false;\n", tabs, tabs( 1 ), result );

		resultVarName_ = result;
	}
}
