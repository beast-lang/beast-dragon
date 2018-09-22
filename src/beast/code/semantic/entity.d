module beast.code.semantic.entity;

import beast.code.semantic.node;

/// Semantic entity can represent any expression with a context
struct SemanticEntity {

public:
	this(SemanticNode node, SemanticNode context = null, MatchLevel matchLevel = MatchLevel.all) {
		this.node = node;
		this.context = context;
		this.matchLevel = matchLevel;
	}

public:
	SemanticNode node;
	SemanticNode context;
	MatchLevel matchLevel;

	alias node this;

public:
	bool isCtime() {
		return node.isCtime && (context is null || context.isCtime);
	}

public:
	/// Creates a class instance that is in charge of matching the currect callable entity with an argument list
	CallableMatch startCallMatch(AST_Node ast, bool canThrowErrors, MatchLevel matchRestriction) {
		return node.startCallMatch(ast, canThrowErrors, context, matchRestriction);
	}

	/// Resolves call with given arguments (can either be AST_Expression or DataEntity or ranges of both)
	final DataEntity resolveCall(Args...)(AST_Node ast, bool reportErrors, MatchLevel matchRestriction, Args args) {
		auto _gd = ErrorGuard(ast);

		CallableMatch match = node.startCallMatch(ast, reportErrors, context, matchRestriction).args(args).finish();
		benforce(match.matchLevel != MatchLevel.noMatch, E.noMatchingOverload, "%s does not match given arguments: %s".format(identificationString, match.errorStr));
		return match.toDataEntity();
	}

}
