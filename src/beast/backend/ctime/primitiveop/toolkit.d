module beast.backend.ctime.primitiveop.toolkit;

public {
	import beast.backend.toolkit;
	import beast.backend.ctime.codebuilder : CodeBuilder_Ctime;
}

alias CB = CodeBuilder_Ctime;
alias T = Symbol_Type;
alias Op = MemoryPtr;

pragma( inline ) void checkMemoryNotCtime( string arg ) {
	import std.algorithm : startsWith;

	benforce( !arg.startsWith( "CTMEM" ), E.protectedMemory, "Cannot write to ctime variable at runtime" );
}
