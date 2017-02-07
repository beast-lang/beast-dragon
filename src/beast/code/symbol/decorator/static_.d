module beast.code.symbol.decorator.static_;

import beast.code.symbol.toolkit;
import beast.code.symbol.decorator;
import beast.code.symbol.vardecldata;

/// @static; used in variableDeclarationModifier context
final class Symbol_Decorator_Static : Symbol_Decorator {

public:
	override @property Identifier identifier( ) {
		return Identifier.preobtained!"static";
	}

public:
	override DecorationContext canBeAppliedOn( DecoratorASTLevelApplication application ) {
		switch ( application ) {

		case DecoratorASTLevelApplication.variableDeclaration:
			return DecorationContext.variableDeclarationModifier;

		default:
			return DecorationContext._noContext;

		}
	}

public:
	override void apply( VariableDeclarationData data ) {
		benforceHint( data.staticity != Staticity.static_, E.duplicitModification, "@static is reduntant (either implicit or set by another decorator)" );
		data.staticity = Staticity.static_;
	}

}
