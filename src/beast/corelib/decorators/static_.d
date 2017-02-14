module beast.corelib.decorators.static_;

import beast.code.sym.toolkit;
import beast.code.sym.decorator.decorator;
import beast.code.ast.decl.env;

/// @static; used in variableDeclarationModifier context
final class Symbol_Decorator_Static : Symbol_Decorator {

public:
	this( Namespace parentNamespace ) {
		super( parentNamespace );
	}

public:
	override @property Identifier identifier( ) {
		return Identifier.preobtained!"#decorator_static";
	}

public:
	override bool apply_variableDeclarationModifier( VariableDeclarationData data ) {
		benforceHint( !data.isStatic, E.duplicitModification, "@static is reduntant (staticity is either implicit or set by another decorator)" );
		data.isStatic = true;
		return true;
	}

}
