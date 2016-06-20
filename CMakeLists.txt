cmake_minimum_required(VERSION 3.5)
project(nati)

set(CXX_STANDARD 14)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14 -Wall -Werror -pedantic")

link_directories(lib)

include_directories(src)
include_directories(include)

file(GLOB_RECURSE SOURCE_FILES src/*.cpp)
add_executable(nati ${SOURCE_FILES})

# Boost doesn't compile on cygwin without this
target_compile_definitions(nati PRIVATE _BSD_SOURCE)