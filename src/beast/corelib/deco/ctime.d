module beast.corelib.deco.ctime;

import beast.corelib.toolkit;
import beast.code.data.decorator.decorator;
import beast.code.ast.decl.variable;

/// @ctime
final class Symbol_Decorator_Ctime : Symbol_Decorator {

	public:
		this( DataEntity parent ) {
			super( parent );
		}

	public:
		override Identifier identifier( ) {
			return ID!"#decorator_ctime";
		}

	public:
		override bool apply_variableDeclarationModifier( VariableDeclarationData data ) {
			benforceHint( !data.isCtime, E.duplicitModification, "@ctime is redundant" );
			data.isCtime = true;
			return true;
		}

}
