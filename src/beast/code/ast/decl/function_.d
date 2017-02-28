module beast.code.ast.decl.function_;

import beast.code.ast.toolkit;
import beast.code.ast.decl.toolkit;
import beast.code.decorationlist;
import beast.code.data.var.userstatic;
import beast.code.ast.expr.parameterlist;
import beast.code.ast.stmt.codeblock;
import beast.code.data.function_.userstatic;
import beast.code.data.scope_.root;

final class AST_FunctionDeclaration : AST_Declaration {

public:
	static bool canParse( ) {
		assert( 0 );
	}

	/// Continues parsing after "@deco Type name" part ( argument list follows )
	static AST_Declaration parse( CodeLocationGuard _gd, AST_DecorationList decorationList, AST_TypeOrAutoExpression returnType, AST_Identifier identifier ) {
		AST_FunctionDeclaration result = new AST_FunctionDeclaration;
		result.decorationList = decorationList;
		result.returnType = returnType;
		result.identifier = identifier;

		result.parameterList = AST_ParameterList.parse( );
		result.body_ = AST_CodeBlockStatement.parse( );

		result.codeLocation = _gd.get( );
		return result;
	}

public:
	override void executeDeclarations( DeclarationEnvironment env, void delegate( Symbol ) sink ) {
		FunctionDeclarationData declData = new FunctionDeclarationData( env );
		DecorationList decorationList = new DecorationList( decorationList, env.staticMembersParent );

		scope scope_ = new RootDataScope( env.staticMembersParent );

		// Apply possible decorators in the variableDeclarationModifier context
		decorationList.apply_functionDeclarationModifier( declData, scope_ );

		if ( declData.isStatic && !declData.isCtime )
			sink( new Symbol_UserStaticFunction( this, decorationList, declData ) );
		else
			berror( E.unimplemented, "Not implemented" );
	}

	override void buildStatementCode( DeclarationEnvironment env, CodeBuilder cb, DataScope scope_ ) {
		berror( E.unimplemented, "Nested functions are not implemented yet" );
	}

public:
	AST_DecorationList decorationList;
	AST_TypeOrAutoExpression returnType;
	AST_ParameterList parameterList;
	AST_Identifier identifier;
	AST_CodeBlockStatement body_;

protected:
	override InputRange!AST_Node _subnodes( ) {
		// Decoration list can be inherited from decoration block or something, in that case we should not consider it a subnodes
		return nodeRange( returnType, identifier, parameterList, decorationList.codeLocation.isInside( codeLocation ) ? decorationList : null );
	}

}

final class FunctionDeclarationData {

public:
	this( DeclarationEnvironment env ) {
		this.env = env;

		isCtime = env.isCtime;
		isStatic = env.isStatic;
	}

public:
	DeclarationEnvironment env;

public:
	bool isCtime;
	bool isStatic;

}
