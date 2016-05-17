cmake_minimum_required(VERSION 3.5)
project(nati)

set(CXX_STANDARD 11)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall -Werror -pedantic")

include_directories(src)
include_directories(include)

file(GLOB_RECURSE SOURCE_FILES src/*.cpp)

add_executable(nati ${SOURCE_FILES})