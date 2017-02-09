module beast.corelib.decorators.static_;

import beast.code.sym.toolkit;
import beast.code.sym.decorator.decorator;

/// @static; used in variableDeclarationModifier context
final class Symbol_Decorator_Static : Symbol_Decorator {

public:
	override @property Identifier identifier( ) {
		return Identifier.preobtained!"#decorator_static";
	}

public:
	override bool apply_variableDeclarationModifier( Symbol_UserVariable variable ) {
		benforceHint( !variable.isStatic_, E.duplicitModification, "@static is reduntant (either implicit or set by another decorator)" );
		variable.isStatic_ = true;

		return true;
	}

}
