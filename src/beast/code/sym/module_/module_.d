module beast.code.sym.module_.module_;

import beast.code.sym.toolkit;
import beast.corelib.corelib;

/// Module as a symbol
/// See also Module from beast.core.project.module_ with module as project file
abstract class Symbol_Module : Symbol {

public:
	this( ) {
		staticData_ = new StaticData;
	}

public:
	final override DeclType declarationType( ) {
		return DeclType.module_;
	}

	abstract Namespace namespace( );

	final override Namespace parentNamespace( ) {
		return null;
	}

public:
	final override DataEntity data( DataEntity instance = null ) {
		return staticData_;
	}

private:
	StaticData staticData_;

private:
	final class StaticData : DataEntity {

	public:
		this( ) {
			super( null );
		}

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

	public:
		override Overloadset resolveIdentifier( Identifier id ) {
			if ( auto result = super.resolveIdentifier( id ) )
				return result;

			// TODO: Move this to Module core type
			if ( auto result = namespace.resolveIdentifier( id ) )
				return result.map!( x => x.data ).array.Overloadset;

			// TODO: public imports

			return Overloadset( );
		}

		override Overloadset resolveIdentifierRecursively( Identifier id ) {
			if ( auto result = super.resolveIdentifierRecursively( id ) )
				return result;

			if ( this !is coreLibrary.module_ ) { // Prevent recursion
				if ( auto result = coreLibrary.module_.data.resolveIdentifier( id ) )
					return result;
			}

			return Overloadset( );
		}

	}

}
