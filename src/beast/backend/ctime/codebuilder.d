module beast.backend.ctime.codebuilder;

import beast.backend.toolkit;
import beast.code.data.scope_.local;

/// "CodeBuilder" that executes data at compile time
/// Because of its result caching, always use each instance of this codebuilder in one task context only!
final class CodeBuilder_Ctime : CodeBuilder {

	public:
		this( ) {
			debug jobId_ = context.jobId;
		}

	public:
		/// Result of the last "built" (read "executed") code
		MemoryPtr result( ) {
			debug {
				assert( result_ );
				assert( context.jobId == jobId_ );

				auto block = memoryManager.findMemoryBlock( result_ );
				assert( block && !block.isRuntime );
			}

			return result_;
		}

	public:
		override void build_localVariableDefinition( DataEntity_LocalVariable var ) {
			addToScope( var );
		}

	public: // Expression related build commands
		override void build_memoryAccess( MemoryPtr pointer ) {
			debug assert( context.jobId == jobId_ );

			MemoryBlock b = memoryManager.findMemoryBlock( pointer );
			benforce( !b.isRuntime, E.valueNotCtime, b.isLocal ? "Variable '%s' is not ctime".format( b.localVariable.identificationString ) : "Variable is not ctime" );

			result_ = pointer;
		}

	public:
		override void build_primitiveOperation( DataScope scope_, Symbol_RuntimeFunction wrapperFunction, BackendPrimitiveOperation op, DataEntity parentInstance, DataEntity[ ] arguments ) {
			static import beast.backend.ctime.primitiveop;

			if ( wrapperFunction.returnType !is coreLibrary.type.Void ) {
				auto resultVar = new DataEntity_TmpLocalVariable( wrapperFunction.returnType, scope_, true );
				build_localVariableDefinition( resultVar );
				result_ = resultVar.memoryPtr;
			}

			auto subScope = scoped!LocalDataScope( scope_ );
			pushScope( );

			pragma( inline ) static opFunc( string opStr, BackendPrimitiveOperation op )( DataScope scope_, CodeBuilder_Ctime cb, DataEntity inst, DataEntity[ ] args ) {
				static if ( __traits( hasMember, beast.backend.ctime.primitiveop, "primitiveOp_%s".format( opStr ) ) )
					mixin( "beast.backend.ctime.primitiveop.primitiveOp_%s( scope_, cb, inst, args );".format( opStr ) );
				else
					assert( 0, "primitiveOp %s is not implemented for %s".format( opStr, cb.identificationString ) );
			}

			mixin(  //
					"final switch( op ) {\n%s\n}".format(  //
					[ __traits( derivedMembers, BackendPrimitiveOperation ) ].map!(  //
					x => "case BackendPrimitiveOperation.%s: opFunc!( \"%s\", BackendPrimitiveOperation.%s )( subScope, this, parentInstance, arguments ); break;\n".format( x, x, x ) //
					 ).joiner ) );

			popScope( );
			subScope.finish( );
		}

	public:
		final string identificationString( ) {
			return "codebuilder.@ctime";
		}

	package:
		debug size_t jobId_;
		MemoryPtr result_;

}
