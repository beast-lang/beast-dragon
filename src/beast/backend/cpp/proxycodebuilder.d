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
			try {
				super.build_moduleDefinition( module_, content );
			}
			catch ( BeastErrorException exc ) {
				codeResult_ ~= "\n// BUILD ERROR HERE\n";
				typesResult_ ~= "\n// BUILD ERROR HERE\n";
				declarationsResult_ ~= "\n// BUILD ERROR HERE\n";
			}
		}

		override void build_functionDefinition( Symbol_RuntimeFunction func, StmtFunction body_ ) {
			try {
				super.build_functionDefinition( func, body_ );
			}
			catch ( BeastErrorException exc ) {
				codeResult_ ~= "\n// BUILD ERROR HERE\n";
				typesResult_ ~= "\n// BUILD ERROR HERE\n";
				declarationsResult_ ~= "\n// BUILD ERROR HERE\n";
			}
		}

}
