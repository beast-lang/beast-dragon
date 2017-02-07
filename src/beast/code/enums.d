module beast.code.enums;

enum Staticity {
	static_, /// Variable is static (has no context)
	dynamic, /// Variable is dynamic (is member of something/access requires context)
}
