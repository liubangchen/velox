#!/usr/bin/env bash
project_dir=`cd .. ; pwd`
COMPILER_FLAGS="-mavx2 -mfma -mavx -mf16c -masm=intel -mlzcnt"

#yum install centos-release-scl scl-utils
#dnf install gcc-toolset-9-gcc.x86_64 gcc-toolset-9-gdb.x86_64 gcc-toolset-9-build.x86_64 gcc-toolset-9-binutils.x86_64
#yum install devtoolset-9-binutils devtoolset-9-gdb devtoolset-9-gcc-c++ devtoolset-9-gcc
#scl enable devtoolset-9 bash
#scl enable gcc-toolset-9 bash
#source /opt/rh/devtoolset-10/enable
#export CC=/usr/local/opt/gcc@11/bin/gcc
#export CXX=/usr/local/opt/gcc@11/bin/g++


declare -A libs
libs["BOOST"]="${project_dir}/libs/boost"
libs["DOUBLE_CONVERSION"]="${project_dir}/libs/double-conversion"
libs["GOOGLETEST"]="${project_dir}/libs/googletest"
libs["LIBSODIUM"]="${project_dir}/libs/libsodium"
libs["LZO"]="${project_dir}/libs/lzo"
libs["PROTOBUF"]="${project_dir}/libs/protobuf"
libs["RE2"]="${project_dir}/libs/re2"
libs["ZLIB"]="${project_dir}/libs/zlib"
libs["FMT"]="${project_dir}/libs/fmt"
libs["GFLAGS"]="${project_dir}/libs/gflags"
libs["ICU"]="${project_dir}/libs/icu"
libs["LZ4"]="${project_dir}/libs/lz4"
libs["OPENSSL"]="${project_dir}/libs/openssl"
libs["RANGE-V3"]="${project_dir}/libs/range-v3"
libs["SNAPPY"]="${project_dir}/libs/snappy"
libs["ZSTD"]="${project_dir}/libs/zstd"
libs["LIBEVENT"]="${project_dir}/libs/libevent"
libs["GLOG"]="${project_dir}/libs/glog"
libs["LIBDWARF"]="${project_dir}/libs/libdwarf"
libs["LIBUNWIND"]="${project_dir}/libs/libunwind"
libs["LIBAIO"]="${project_dir}/libs/libaio"
libs["FOLLY"]="${project_dir}/libs/folly"
libs["BZIP2"]="${project_dir}/libs/bzip2"

cmake_params=""
cmake_prefix_path=""
cmake_inc=""
cmake_libs=""

for key in ${!libs[@]};do
    cmake_params="-D${key}_ROOT=${libs[${key}]} ${cmake_params}"
    cmake_prefix_path="${libs[${key}]};${cmake_prefix_path}"
    cmake_inc="${libs[${key}]}/include:${cmake_inc}"
    cmake_libs="${libs[${key}]}/lib:${libs[${key}]}/lib64:${cmake_libs}"
done

#-DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang  -DCMAKE_CXX_FLAGS="-stdlib=libc++"
#cmake version 3.18.2
#yum install ninja-build

cmake   ${cmake_params} -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang -DCMAKE_BUILD_TYPE=Release  -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
        -DCMAKE_FIND_USE_CMAKE_ENVIRONMENT_PATH=YES \
        -DBUILD_TESTS=OFF \
        -DVELOX_ENABLE_EXAMPLES=OFF \
        -DCMAKE_CXX_STANDARD=17 \
        -DCMAKE_FIND_LIBRARY_SUFFIXES=".a" \
        -DCMAKE_CXX_FLAGS="-std=c++17" \
        -DVELOX_BUILD_TESTING=OFF  \
        -DCMAKE_PREFIX_PATH=${cmake_prefix_path} \
        -DCMAKE_INCLUDE_PATH=${cmake_inc} \
        -DCMAKE_LIBRARY_PATH=${cmake_libs} -DEVENT= ../

make -j32
