import std.file;
import std.datetime;
import std.conv;
import std.string;

void main() {
	SysTime tm = Clock.currTime;

	copy( "projekt.pdf", tm.year.to!string ~ "-" ~ tm.month.to!ubyte.to!string.rightJustify( 2, '0' ) ~ "-" ~ tm.day.to!string.rightJustify( 2, '0' ) ~ "_xcejch00_isp.pdf" );
}