#include <iostream>
#include <nati/lexical/IdentifierTable.h>

using namespace std;

int main() {
	nati::identifierTable = new nati::IdentifierTable();

	cout << "Hello, World!" << endl;

	delete nati::identifierTable;

	return 0;
}