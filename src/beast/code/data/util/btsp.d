module beast.code.data.util.btsp;

import beast.code.data.toolkit;
import beast.code.data.decorator.decorator;
import beast.code.data.callable.match;

/// Data entity whose parameters are passed in the constructor
abstract class DataEntity_Bootstrap : DataEntity {

	public:
		alias BuildCodeFunc = void delegate( CodeBuilder cb );

	public:
		this( Symbol_Type dataType, DataEntity parent, bool isCtime, BuildCodeFunc buildCodeFunc, MatchLevel matchLevel = MatchLevel.fullMatch ) {
			super( matchLevel );

			dataType_ = dataType;
			parent_ = parent;
			isCtime_ = isCtime;
			buildCodeFunc_ = buildCodeFunc;
		}

	public:
		override Symbol_Type dataType( ) {
			return dataType_;
		}

		override DataEntity parent( ) {
			return parent_;
		}

		override bool isCtime( ) {
			return isCtime_;
		}

		override void buildCode( CodeBuilder cb ) {
			buildCodeFunc_( cb );
		}

	public:
		override Identifier identifier( ) {
			return null;
		}

		override string identification( ) {
			return "#btsp#";
		}

		override AST_Node ast( ) {
			return null;
		}

		override Hash outerHash( ) {
			return Hash( 0 );
		}

	protected:
		DataEntity parent_;
		BuildCodeFunc buildCodeFunc_;
		Symbol_Type dataType_;
		bool isCtime_;

}
