cmake_minimum_required(VERSION 3.10)

project(HashMap)

# 设置 C++ 标准（如果是 C 语言，可删除此行；根据需要指定版本，如 11/17/20）
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -g -O0 -Wall")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3 -Wall")

# 添加源文件：这里假设源文件名为 main.cpp（如果是 C 语言则改为 main.c）
add_executable(main main.cpp)