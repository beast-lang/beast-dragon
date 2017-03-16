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
		override void build_primitiveOperation( Symbol_RuntimeFunction wrapperFunction, BackendPrimitiveOperation op, DataEntity parentInstance, DataEntity[ ] arguments ) {
			static import beast.backend.ctime.primitiveop;

			debug result_ = MemoryPtr( );

			if ( wrapperFunction.returnType !is coreLibrary.type.Void ) {
				auto resultVar = new DataEntity_TmpLocalVariable( wrapperFunction.returnType, false );
				build_localVariableDefinition( resultVar );
			}

			auto _s = scoped!LocalDataScope( );
			auto _sgd = _s.scopeGuard;
			pushScope( );

			mixin( ( ) { //
				import std.array : appender;

				auto result = appender!string;
				result ~= "final switch( op ) {\n";

				foreach ( opStr; __traits( derivedMembers, BackendPrimitiveOperation ) ) {
					result ~= "case BackendPrimitiveOperation.%s:\n".format( opStr );

					static if ( __traits( hasMember, beast.backend.ctime.primitiveop, "primitiveOp_%s".format( opStr ) ) )
						result ~= "beast.backend.ctime.primitiveop.primitiveOp_%s( this, parentInstance, arguments );\nbreak;\n".format( opStr );
					else
						result ~= "assert( 0, \"primitiveOp %s is not implemented for codebuilder.ctime\" );\n".format( opStr );
				}

				result ~= "}\n";
				return result.data;
			}( ) );

			popScope( );
			_s.finish( );
		}

	public:
		final string identificationString( ) {
			return "codebuilder.@ctime";
		}

	package:
		debug size_t jobId_;
		MemoryPtr result_;

}
