module beast.code.semantic.expr;

import beast.code.semantic.type.type;
import beast.code.semantic.namespace.namespace;
import beast.code.ast.node;
import beast.code.lex.identifier;
import beast.core.project.codelocation;
import beast.code.semantic.callable.match;
import beast.util.identifiable;

/// Semantic node can represent any expression, variable, data or symbol from a semantic point of view
/// In same cases, semantic node is not enough to build a code - for example Class.memberVariable needs context in a form of class instance -> because of that, we mainly use SemanticEntity which covers that
abstract class SemanticNode : Identifiable {

public:
	/// Optional node identifier - for example class name, variable name, etc (can be null)
	Identifier identifier() {
		return null;
	}

	/// Data type of the semantic node; cannot be null (for these cases, use Void)
	abstract Symbol_Type dataType();

	/// Namespace the node belongs to; can be null (is used for identification purposes)
	abstract Namespace namespace();

	/// If the semantic node was generated from an AST, this function should return an appropriate AST node. Can be null.
	abstract AST_Node ast();

	/// Location in the code related to the data entity
	final CodeLocation codeLocation() {
		return ast ? ast.codeLocation : null.to!CodeLocation;
	}

	/// Returns if the semanticNode requires context to compile - for example Class.nonStaticVariable requires class instance as a context
	abstract bool requiresContext();

	/// Returns if the current entity is ctime - its value can be determined in compile time
	abstract bool isCtime();

public:
	string identification() {
		if (auto id = identifier)
			return id.str;

		return "#tmp#";
	}

	string identificationString() {
		if (auto namespace = namespace)
			return "%s.%s".format(namespace.identificationString, identification);
		else
			return identification;
	}

public:
	Overloadset tryResolveIdentifier(Identifier id, SemanticNode context) {
		if (id == ID!"#type")
			return dataType.SemanticEntity(null).Overloadset;

		if (auto result = _resolveIdentifier_pre(id, matchLevel))
			return result;

		if (auto result = _resolveIdentifier_main(id, matchLevel))
			return result;

		if (auto result = dataType.tryResolveIdentifier(id, this, matchLevel))
			return result;

	}

public:
	bool isCallable() {
		return false;
	}

	/// Creates a class instance that is in charge of matching the currect callable entity with an argument list
	CallableMatch startCallMatch(AST_Node ast, bool canThrowErrors, SemanticNode context, MatchLevel matchRestriction) {
		assert(0, identificationString ~ " is not callable");
	}

}
