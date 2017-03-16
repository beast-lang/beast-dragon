module beast.code.data.module_.module_;

import beast.code.data.toolkit;
import beast.code.data.codenamespace.namespace;
import beast.core.error.error;

/// Module as a symbol
/// See also Module from beast.core.project.module_ with module as project file
abstract class Symbol_Module : Symbol {

	public:
		this( ) {
			staticData_ = new Data;
			importSpaceData_ = new ImportSpaceData;
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
				bool error = false;

				foreach ( sym; namespace.members ) {
					try {
						sym.buildDefinitionsCode( cb );
					}
					catch ( BeastErrorException exc ) {
						error = true;
					}
				}

				if ( error )
					throw new BeastErrorException( "#moduleBuildError" );
			} );
		}

	protected:
		abstract Namespace namespace( );

	private:
		Data staticData_;
		ImportSpaceData importSpaceData_;

	private:
		final class Data : SymbolRelatedDataEntity {

			public:
				this( ) {
					super( this.outer );
				}

			public:
				override Symbol_Type dataType( ) {
					// TODO: Module reflection type
					return coreLibrary.type.Void;
				}

				override bool isCtime( ) {
					return true;
				}

				override DataEntity parent( ) {
					return importSpaceData_;
				}

			public:
				override string identificationString( ) {
					return identification;
				}

			protected:
				protected override Overloadset _resolveIdentifier_main( Identifier id, DataScope scope_ ) {
					// TODO: Copy this to Module core type
					if ( auto result = namespace.resolveIdentifier( id, null ) )
						return result;

					return Overloadset( );
				}

		}

		final class ImportSpaceData : DataEntity {

			public:
				override Symbol_Type dataType( ) {
					// TODO: Maybe better dataType?
					return coreLibrary.type.Void;
				}

				override bool isCtime( ) {
					return true;
				}

				override DataEntity parent( ) {
					return null;
				}

			public:
				override AST_Node ast( ) {
					return null;
				}

				override Hash outerHash( ) {
					return Hash( );
				}

			protected:
				override Overloadset _resolveIdentifier_main( Identifier id, DataScope scope_ ) {
					// TODO: imports and public imports

					if ( this.outer !is coreLibrary.module_ ) {
						if ( auto result = coreLibrary.module_.dataEntity.resolveIdentifier( id, scope_ ) )
							return result;
					}

					return Overloadset( );
				}

		}

}
