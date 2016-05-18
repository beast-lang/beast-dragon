cmake_minimum_required(VERSION 3.5)
project(nati)

set(CXX_STANDARD 11)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall -Werror -pedantic")

link_directories(lib)

include_directories(src)
include_directories(include)

file(GLOB_RECURSE SOURCE_FILES src/*.cpp)
add_executable(nati ${SOURCE_FILES} src/nati/mgmt/TaskContext.cpp src/nati/mgmt/TaskContext.h)
target_link_libraries(nati boost_atomic boost_context boost_date_time boost_exception boost_filesystem boost_chrono boost_prg_exec_monitor boost_program_options boost_regex boost_system boost_test_exec_monitor boost_thread boost_timer boost_unit_test_framework)

# Boost doesn't compile on cygwin without this
target_compile_definitions(nati PRIVATE _BSD_SOURCE)