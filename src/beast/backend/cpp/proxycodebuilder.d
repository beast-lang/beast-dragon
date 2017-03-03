module beast.backend.cpp.proxycodebuilder;

import beast.backend.toolkit;
import beast.backend.cpp.codebuilder;

/// Proxy codebuilder processes independent symbols parallel and does not stop the entire building because of one exception
final class CodeBuilder_CppProxy : CodeBuilder_Cpp {

	public:
		this( CodeBuilder_Cpp parent ) {
			super( parent );
		}

	public:
		override void build_moduleDefinition( Symbol_Module module_, DeclFunction content ) {
			auto tmp = result_;
			result_ = appender!string;

			try {
				super.build_moduleDefinition( module_, content );
				tmp ~= result_.data;
			}
			catch ( BeastErrorException exc ) {
			}

			result_ = tmp;
		}

		override void build_functionDefinition( Symbol_RuntimeFunction func, StmtFunction body_ ) {
			auto tmp = result_;
			result_ = appender!string;

			try {
				super.build_functionDefinition( func, body_ );
				tmp ~= result_.data;
			}
			catch ( BeastErrorException exc ) {
			}

			result_ = tmp;
		}

}
