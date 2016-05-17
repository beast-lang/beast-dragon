#include <iostream>
#include <nati/lexical/IdentifierTable.h>
#include <nati/mgmt/TaskManager.h>

using namespace std;
using namespace nati;

int main() {
	identifierTable = new IdentifierTable();
	taskManager = new TaskManager();

	cout << "Hello, World!" << endl;

	delete taskManager;
	delete identifierTable;

	return 0;
}