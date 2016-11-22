import std.file;
import std.datetime;
import std.conv;

void main() {
	SysTime tm = Clock.currTime;

	copy( "projekt.pdf", tm.year.to!string ~ "-" ~ tm.month.to!ubyte.to!string ~ "-" ~ tm.day.to!string ~ "_xcejch00_isp.pdf" );
}