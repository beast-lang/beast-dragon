module beast.code.ast.decl.variable;

import beast.code.ast.toolkit;
import beast.code.ast.decl.toolkit;
import beast.code.decorationlist;
import beast.code.data.var.userstatic;
import beast.code.data.var.local;
import beast.code.data.scope_.root;
import beast.code.data.var.userlocal;

final class AST_VariableDeclaration : AST_Declaration {

public:
	static bool canParse( ) {
		assert( 0 );
	}

	/// Continues parsing after "@deco Type name" part ( "= value;", ":= value;" or ";" can follow )
	static AST_Declaration parse( CodeLocationGuard _gd, AST_DecorationList decorationList, AST_Expression type, AST_Identifier identifier ) {
		AST_VariableDeclaration result = new AST_VariableDeclaration;
		result.decorationList = decorationList;
		result.type = type;
		result.identifier = identifier;

		if ( currentToken.matchAndNext( Token.Operator.assign ) )
			result.value = AST_Expression.parse( );

		else if ( currentToken.matchAndNext( Token.Operator.colonAssign ) ) {
			result.valueColonAssign = true;
			result.value = AST_Expression.parse( );
		}
		else
			currentToken.expect( Token.Special.semicolon, "default value or ';'" );

		currentToken.expectAndNext( Token.Special.semicolon );

		result.codeLocation = _gd.get( );
		return result;
	}

public:
	override void executeDeclarations( DeclarationEnvironment env, void delegate( Symbol ) sink ) {
		VariableDeclarationData declData = new VariableDeclarationData( env );
		DecorationList decorationList = new DecorationList( decorationList, env.staticMembersParent );

		scope scope_ = new RootDataScope( env.staticMembersParent );

		// Apply possible decorators in the variableDeclarationModifier context
		decorationList.apply_variableDeclarationModifier( declData, scope_ );

		if ( declData.isStatic )
			sink( new Symbol_UserStaticVariable( this, decorationList, declData ) );
		else
			berror( E.notImplemented, "Not implemented" );
	}

	override void buildStatementCode( DeclarationEnvironment env, CodeBuilder cb, DataScope scope_ ) {
		VariableDeclarationData declData = new VariableDeclarationData( env );
		DecorationList decorationList = new DecorationList( decorationList, env.staticMembersParent );

		// Apply possible decorators in the variableDeclarationModifier context
		decorationList.apply_variableDeclarationModifier( declData, scope_ );

		benforce( !declData.isStatic, E.notImplemented, "Static variables in function bodies are not implemented yet" );

		DataEntity_UserLocalVariable var = new DataEntity_UserLocalVariable( this, decorationList, declData );
		scope_.addLocalVariable( var );

		cb.build_localVariableDefinition( var );
	}

public:
	AST_DecorationList decorationList;
	AST_Expression type;
	AST_Identifier identifier;
	AST_Expression value;
	/// True if variable was declarated using "@deco Type name := value"
	bool valueColonAssign;

protected:
	override InputRange!AST_Node _subnodes( ) {
		// Decoration list can be inherited from decoration block or something, in that case we should not consider it a subnodes
		return nodeRange( type, identifier, value, decorationList.codeLocation.isInside( codeLocation ) ? decorationList : null );
	}

}

final class VariableDeclarationData {

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
