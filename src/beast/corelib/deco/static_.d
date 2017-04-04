module beast.corelib.deco.static_;

import beast.corelib.toolkit;
import beast.code.data.decorator.decorator;
import beast.code.ast.decl.variable;
import beast.code.ast.decl.function_;
import beast.code.ast.decl.class_;

/// @static; used in variableDeclarationModifier context
final class Symbol_Decorator_Static : Symbol_Decorator {

	public:
		this( DataEntity parent ) {
			super( parent );
		}

	public:
		override Identifier identifier( ) {
			return ID!"#decorator_static";
		}

	public:
		override bool apply_variableDeclarationModifier( VariableDeclarationData data ) {
			benforceHint( !data.isStatic, E.duplicitModification, "@static is redundant (staticity is either implicit or set by another decorator)" );
			data.isStatic = true;
			return true;
		}

		override bool apply_functionDeclarationModifier( FunctionDeclarationData data ) {
			benforceHint( !data.isStatic, E.duplicitModification, "@static is redundant (staticity is either implicit or set by another decorator)" );
			data.isStatic = true;
			return true;
		}

		override bool apply_classDeclarationModifier( ClassDeclarationData data ) {
			benforceHint( !data.isStatic, E.duplicitModification, "@static is redundant (staticity is either implicit or set by another decorator)" );
			data.isStatic = true;
			return true;
		}

}
