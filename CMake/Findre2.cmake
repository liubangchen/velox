# Copyright (c) Facebook, Inc. and its affiliates.
# - Try to find Glog
# Once done, this will define
#
# GLOG_FOUND - system has Glog
# GLOG_INCLUDE_DIRS - the Glog include directories
# GLOG_LIBRARIES - link these to use Glog

if(DEFINED RE2_FOUND)
  return()
endif()

set(RE2_ROOT "${PROJECT_SOURCE_DIR}/libs/re2")

find_library(
  RE2_LIBRARY
  NAMES re2
  PATHS ${RE2_ROOT}/lib
)

find_path(
  RE2_INCLUDE_DIR re2/re2.h
  PATHS ${RE2_ROOT}/include
)

include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(
  re2
  REQUIRED_VARS RE2_INCLUDE_DIR RE2_LIBRARY
  FOUND_VAR RE2_FOUND
)

mark_as_advanced(
  RE2_LIBRARY
  RE2_INCLUDE_DIR
)
include_directories(${RE2_INCLUDE_DIR})
set(RE2_LIBRARIES ${RE2_LIBRARY})
set(RE2_INCLUDE_DIRS ${RE2_INCLUDE_DIR})


##if(NOT TARGET glog::glog)
##  add_library(glog::glog UNKNOWN IMPORTED)
##  set_target_properties(glog::glog PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${GLOG_INCLUDE_DIRS}")
##  set_target_properties(glog::glog PROPERTIES IMPORTED_LINK_INTERFACE_LANGUAGES "C" IMPORTED_LOCATION "${GLOG_LIBRARIES}")
##endif()
