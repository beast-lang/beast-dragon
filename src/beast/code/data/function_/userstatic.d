module beast.code.data.function_.userstatic;

import beast.code.data.toolkit;
import beast.code.data.function_.function_;

final class Symbol_UserStaticFunction : Symbol_Function {

public:
	this( AST_FunctionDeclaration ast, DecorationList decorationList, FunctionDeclarationData data ) {
		ast_ = ast;
		decorationList_ = decorationList;
		staticData_ = new Data;
		parent_ = data.env.staticMembersParent;
	}

	override Identifier identifier( ) {
		return ast_.identifier;
	}

	override AST_Node ast( ) {
		return ast_;
	}

	final override DeclType declarationType( ) {
		return DeclType.staticFunction;
	}

public:
	final override DataEntity dataEntity( DataEntity parentInstance = null ) {
		return staticData_;
	}

public:
	/// Tries to match the function with given arguments
	override FunctionMatch match( FunctionArgument[ ] args ) {
		assert( 0 );
	}

private:
	AST_FunctionDeclaration ast_;
	DecorationList decorationList_;
	Data staticData_;
	DataEntity parent_;

private:
	final class Data : SymbolRelatedDataEntity {

	public:
		this( ) {
			super( this.outer );
		}

	public:
		override Symbol_Type dataType( ) {
			assert( 0 );
		}

		override bool isCtime( ) {
			return true;
		}

		override DataEntity parent( ) {
			return this.outer.parent_;
		}

	}

}
