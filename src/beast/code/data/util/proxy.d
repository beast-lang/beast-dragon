module beast.code.data.util.proxy;

import beast.code.data.toolkit;
import beast.code.data.decorator.decorator;
import beast.code.data.callable;

/// Proxy data entity that passes everything to the source entity; used as an utility for other data entities
abstract class ProxyDataEntity : DataEntity {

	public:
		this( DataEntity sourceEntity ) {
			assert( sourceEntity );
			sourceEntity_ = sourceEntity;
		}

	public:
		override Symbol_Type dataType( ) {
			return sourceEntity_.dataType;
		}

		override DataEntity parent( ) {
			return sourceEntity_.parent;
		}

		override bool isCtime( ) {
			return sourceEntity_.isCtime;
		}

		override bool isCallable( ) {
			return sourceEntity_.isCallable;
		}

		override CallableMatch startCallMatch( AST_Node ast ) {
			return sourceEntity_.startCallMatch( ast );
		}

		override Symbol_Decorator isDecorator( ) {
			return sourceEntity_.isDecorator;
		}

	public:
		override Identifier identifier( ) {
			return sourceEntity_.identifier;
		}

		override string identification( ) {
			return sourceEntity_.identification;
		}

		override AST_Node ast( ) {
			return sourceEntity_.ast;
		}

		override Hash outerHash( ) {
			return sourceEntity_.outerHash;
		}

	protected:
		final override Overloadset _resolveIdentifier_main( Identifier id ) {
			return sourceEntity_.resolveIdentifier( id );
		}

	protected:
		DataEntity sourceEntity_;

}
