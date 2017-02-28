module beast.code.data.module_.module_;

import beast.code.data.toolkit;
import beast.corelib.corelib;

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

public:
	final override DataEntity dataEntity( DataEntity instance = null ) {
		return staticData_;
	}

	final override void buildDefinitionsCode( CodeBuilder cb ) {
		cb.build_moduleDefinition( this, ( cb ) {
			foreach ( sym; namespace.members )
				sym.buildDefinitionsCode( cb );
		} );
	}

protected:
	abstract Namespace namespace( );
	
private:
	Data staticData_;

private:
	final class Data : SymbolRelatedDataEntity {

	public:
		this( ) {
			super( this.outer );
		}

	public:
		override Symbol_Type dataType( ) {
			// TODO: Module reflection type
			return null;
		}

		override bool isCtime( ) {
			return true;
		}

		override DataEntity parent( ) {
			return null;
		}

	public:
		protected final override Overloadset resolveIdentifier_main( Identifier id, DataScope scope_ ) {
			// TODO: Move this to Module core type
			if ( auto result = namespace.resolveIdentifier( id, null ) )
				return result;

			// TODO: public imports

			return Overloadset( );
		}

		override Overloadset recursivelyResolveIdentifier( Identifier id, DataScope scope_ ) {
			if ( auto result = resolveIdentifier( id, scope_ ) )
				return result;

			// Look into core library
			if ( this.outer !is coreLibrary.module_ ) {
				if ( auto result = coreLibrary.module_.dataEntity.resolveIdentifier( id, scope_ ) )
					return result;
			}

			return Overloadset( );
		}

	}

}
