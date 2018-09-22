module beast.code.semantic.util.proxy;

import beast.code.semantic.toolkit;
import beast.code.semantic.decorator.decorator;
import beast.code.semantic.callable.match;

/// Proxy data entity that passes everything to the source entity; used as an utility for other data entities
abstract class ProxySemanticNode : SemanticNode {

public:
	this(SemanticNode source) {
		assert(source);
		source_ = source;
	}

public:
	override Identifier identifier() {
		return source_.identifier;
	}

	override Symbol_Type dataType() {
		return source_.dataType;
	}

	override Namespace namespce() {
		return source_.namespace;
	}

	override AST_Node ast() {
		return source_.ast;
	}

	override bool requiresContext() {
		return source_.requiresContext;
	}

	override bool isCtime() {
		return source_.isCtime;
	}

	override bool isCallable() {
		return source_.isCallable;
	}

	override CallableMatch startCallMatch(AST_Node ast, bool canThrowErrors, SemanticNode context, MatchLevel matchRestriction) {
		return source_.startCallMatch(ast, canThrowErrors, context, matchRestriction);
	}

protected:
	DataEntity source_;

}
