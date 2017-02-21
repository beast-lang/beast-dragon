module beast.code.sym.function_.userstatic;

import beast.code.sym.toolkit;
import beast.code.sym.function_.function_;
import beast.code.data.entity.symnolrelated;
import beast.code.data.toolkit;

final class Symbol_UserStaticFunction : Symbol_Function {

public:
	this( AST_FunctionDeclaration ast, DecorationList decorationList, DeclarationEnvironment env ) {
		ast_ = ast;
		parentNamespace_ = env.parentNamespace;
		decorationList_ = decorationList;
		staticData_ = new Data;
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

	final override Namespace parentNamespace( ) {
		return parentNamespace_;
	}

public:
	final override DataEntity data( DataEntity parentInstance = null ) {
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
	Namespace parentNamespace_;
	Data staticData_;

private:
	final class Data : SymbolRelatedDataEntity {

	public:
		this( ) {
			super( null, this.outer );
		}

	public:
		override Symbol_Type dataType( ) {
			assert( 0 );
		}

		override bool isCtime( ) {
			return true;
		}

	public:
		override void buildCode( CodeBuilder cb, DataScope scope_ ) {
			// TODO:
			cb.build_staticMemoryAccess( MemoryPtr( 0 ) );
		}

	}

}
