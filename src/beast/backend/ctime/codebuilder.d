module beast.backend.ctime.codebuilder;

import beast.backend.toolkit;
import beast.code.data.scope_.local;
import beast.backend.interpreter.interpreter;
import beast.util.uidgen;

/// "CodeBuilder" that executes data at compile time
/// Because of its result caching, always use each instance of this codebuilder in one task context only!
final class CodeBuilder_Ctime : CodeBuilder {

	public:
		this( ) {
			debug jobId_ = context.jobId;
		}

	public:
		override bool isCtime( ) {
			return true;
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
			benforce( !b.isRuntime, E.valueNotCtime, "Variable %s is not ctime".format( b.identificationString ) );

			result_ = pointer;
		}

		override void build_offset( ExprFunction expr, size_t offset ) {
			expr( this );
			result_.val += offset;
		}

	public:
		override void build_functionCall( Symbol_RuntimeFunction function_, DataEntity parentInstance, DataEntity[ ] arguments ) {
			// We execute the runtime function using the interpreter

			MemoryPtr result;
			if ( function_.returnType !is coreType.Void ) {
				auto resultVar = new DataEntity_TmpLocalVariable( function_.returnType, true );
				build_localVariableDefinition( resultVar );

				result = resultVar.memoryPtr;
			}

			auto _s = new LocalDataScope( );
			auto _sgd = _s.scopeGuard;
			pushScope( );

			MemoryPtr ctx;
			if ( function_.declarationType == Symbol.DeclType.memberFunction ) {
				auto var = new DataEntity_TmpLocalVariable( coreType.Pointer, true, "ctx" );
				build_localVariableDefinition( var );
				super.build_primitiveOperation( BackendPrimitiveOperation.markPtr, var );

				assert( parentInstance );
				parentInstance.buildCode( this );

				var.memoryPtr.writeMemoryPtr( result_ );
				ctx = var.memoryPtr;
			}

			MemoryPtr[ ] args;
			foreach ( i, param; function_.parameters ) {
				auto argVar = new DataEntity_TmpLocalVariable( param.dataType, true );
				build_localVariableDefinition( argVar );
				build_copyCtor( argVar, arguments[ i ] );

				args ~= argVar.memoryPtr;
			}

			Interpreter.executeFunction( function_, result, ctx, args );

			popScope( );
			_s.finish( );

			result_ = result;
		}

		mixin Build_PrimitiveOperationImpl!( "ctime", "result_" );

	public:
		override void build_scope( StmtFunction body_ ) {
			pushScope( );
			body_( this );
			popScope( );
		}

	public:
		override void popScope( bool generateDestructors = true ) {
			// Result might be f-ked around because of destructors
			auto result = result_;

			super.popScope( generateDestructors );

			result_ = result_;
		}

	public:
		final string identificationString( ) {
			return "codebuilder.@ctime";
		}

	package:
		debug UIDGenerator.I jobId_;
		MemoryPtr result_;

}
