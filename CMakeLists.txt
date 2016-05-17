cmake_minimum_required(VERSION 3.5)
project(nati)

set(CXX_STANDARD 11)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall -Werror -pedantic")

include_directories(src)

set(SOURCE_FILES src/nati/main.cpp src/nati/mgmt/ModuleManager.cpp src/nati/mgmt/ModuleManager.h src/nati/ast/AST_ExtendedIdentifier.cpp src/nati/ast/AST_ExtendedIdentifier.h src/nati/lexical/Identifier.cpp src/nati/lexical/Identifier.h src/nati/lexical/Lexer.cpp src/nati/lexical/Lexer.h src/nati/lexical/LexerState.h src/nati/lexical/Token.cpp src/nati/lexical/Token.h src/nati/lexical/IdentifierTable.cpp src/nati/lexical/IdentifierTable.h)
add_executable(nati ${SOURCE_FILES})