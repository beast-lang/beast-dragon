module beast.code.sym.type.staticclass;

import beast.code.sym.toolkit;
import beast.code.sym.type.class_;

abstract class Symbol_StaticClassType : Symbol_ClassType {

public:
	final override DeclType declarationType( ) {
		return DeclType.staticClass;
	}

public:
	final override @property DataEntity data( DataEntity parentInstance ) {
		return new class DataEntity {

		public:
			this( ) {
				// Static variables are in global scope
				super( null );
			}

		public:
			override @property Symbol_Type dataType( ) {
				return coreLibrary.types.Type;
			}

			override @property bool isCtime( ) {
				return true;
			}

			override @property Identifier identifier( ) {
				return this.outer.identifier;
			}

			override @property string identificationString( ) {
				return this.outer.identificationString;
			}

		};
	}

}
