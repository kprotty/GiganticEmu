cmake_minimum_required(VERSION 3.0)
project(ArcSDK CXX)

add_library(ArcSDK SHARED ArcSDK.h json.hpp main.cpp)
