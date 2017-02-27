module beast.code.data.module_.module_;

import beast.code.data.toolkit;
import beast.corelib.corelib;
import beast.code.data.toolkit;

/// Module as a symbol
/// See also Module from beast.core.project.module_ with module as project file
abstract class Symbol_Module : Symbol {

public:
	this( ) {
		staticData_ = new Data;
	}

public:
	final override DeclType declarationType( ) {
		return DeclType.module_;
	}

	final override void parent( EntityContainer set ) {
		assert( 0 );
	}

	abstract Namespace namespace( );

public:
	final override DataEntity data( DataEntity instance = null ) {
		return staticData_;
	}

private:
	Data staticData_;

private:
	final class Data : DataEntity {

	public:
		override Symbol_Type dataType( ) {
			// TODO: Module reflection type
			return coreLibrary.types.Void;
		}

		override bool isCtime( ) {
			return false;
		}

		override Identifier identifier( ) {
			return this.outer.identifier;
		}

		override string identificationString( ) {
			return this.outer.identificationString;
		}

		override AST_Node ast( ) {
			return this.outer.ast;
		}

	public:
		override Overloadset resolveIdentifier( Identifier id ) {
			if ( auto result = super.resolveIdentifier( id ) )
				return result;

			// TODO: Move this to Module core type
			if ( auto result = namespace.resolveIdentifier( id, null ) )
				return result;

			// TODO: public imports

			return Overloadset( );
		}

	public:
		override void buildCode( CodeBuilder cb, DataScope scope_ ) {
			assert( 0, "Not implemented" );
		}

	}

}
