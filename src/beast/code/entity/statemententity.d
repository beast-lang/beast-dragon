module besat.code.entity.statemententity;

/// Basically a non-expression semantic tree node
class StatementEntity {

public:
	abstract void buildCode(CodeBuilder cb);

}
