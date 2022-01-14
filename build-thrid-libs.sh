#!/usr/bin/env bash

project_dir=`pwd`

function build_cmake_package(){
    local version=$1
    local mname=$2
    local subdir=$3
    local cmake_params=$4

    cd $project_dir/contrib/$mname
    git checkout $version

    if [ -z "$subdir" ]; then
        echo "subdir is empty"
    else
        cd $subdir
    fi

    rm -rf _build
    mkdir -p _build
    cd _build
    if [ -f $project_dir/contrib/$mname/build/cmake/CMakeLists.txt ]; then
        cmake $cmake_params -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ -DCMAKE_CXX_FLAGS="-std=c++11" -DCMAKE_INSTALL_PREFIX=$project_dir/libs/$mname ${project_dir}/contrib/${mname}/build/cmake/
    else
        cmake $cmake_params -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ -DCMAKE_CXX_FLAGS="-std=c++11" -DCMAKE_INSTALL_PREFIX=$project_dir/libs/$mname ../
    fi
    make -j32
    make install
    cd ..
    rm -rf _build
    cd $project_dir/contrib/$mname
    if [ -d ".git" ] ;then
        git reset --hard
        git clean -fd
    fi
}

function build_makefile_package(){
    local version=$1
    local mname=$2
    local subdir=$3
    local params=$4

    cd $project_dir/contrib/$mname
    git checkout $version

    if [ -z "$subdir" ]; then
        echo "subdir is empty"
    else
        cd $subdir
    fi

    if [ -f "autogen.sh" ]; then
        ./autogen.sh
    fi

    if [ -f "configure.ac" ]; then
        #autoreconf -i
        echo "test"
    fi

    if [ -f "configure" ]; then
        ./configure --prefix=$project_dir/libs/$mname ${params}
        make clean
        make -j32
        make install
        make clean

    elif [ -f "Configure" ]; then
        ./Configure --prefix=$project_dir/libs/${mname} ${params}
        make clean
        make -j32
        make install
        make clean
    elif [ -f "config" ]; then
        ./config --prefix=$project_dir/libs/${mname} ${params}
        make clean
        make -j32
        make install
        make clean
    else
        make clean
        env CC = clang CXX=clang ; make -j32
        make DESTDIR=$project_dir/libs/${mname} install
        make clean
    fi

    cd $project_dir/contrib/$mname
    if [ -d ".git" ] ;then
        git reset --hard
        git clean -fd
    fi
}

function build_boosts(){
    cd $project_dir/contrib/boost_1_66_0
    #compiler.blacklist clang --with-toolset=clang
    ./bootstrap.sh --prefix=$project_dir/libs/boost --with-icu=$project_dir/libs/icu --with-toolset=gcc
    #compiler.blacklist clang --with-toolset=clang
    ./b2 link=static runtime-link=static threading=multi variant=release runtime-link=static --prefix=$project_dir/libs/boost -j32
    ./b2 install
    ./b2 --clean
}

function build_base_deps(){
    ##build fmt
    build_cmake_package "7.1.3" "fmt"
    ##build icu4c ./runConfigureICU Linux/gcc
    build_makefile_package "release-70-1" "icu" "icu4c/source" "--disable-shared --enable-static"
    ##build boosts
    build_boosts
    build_cmake_package "release-1.10.0" "googletest"
    build_cmake_package "v3.1.5" "double-conversion"
    build_cmake_package "master" "range-v3" "" "-DRANGES_ENABLE_WERROR=OFF -DRANGE_V3_TESTS=OFF -DRANGE_V3_EXAMPLES=OFF"
    build_cmake_package "2021-04-01" "re2" "" "-DRE2_BUILD_TESTING=OFF -DCMAKE_INSTALL_LIBDIR=lib"
    build_cmake_package "master" "bzip2" "" "-DENABLE_STATIC_LIB=ON -DENABLE_SHARED_LIB=OFF -DCMAKE_INSTALL_LIBDIR=lib"
    build_makefile_package "OpenSSL_1_1_1m" "openssl" "" "linux-x86_64"
    build_cmake_package "v2.2.2" "gflags" "" "-DBUILD_STATIC_LIBS=1 -DINSTALL_HEADERS=1 -DBUILD_SHARED_LIBS=1"
    build_makefile_package "1.0.9" "libsodium"
    build_cmake_package "v0.5.0" "glog" "" "-DBUILD_SHARED_LIBS=OFF -DCMAKE_INSTALL_LIBDIR=lib"
    build_makefile_package "v3.19.0" "protobuf" "" "--disable-shared --enable-static"
    build_cmake_package "v1.9.3" "lz4" "" "-DBUILD_STATIC_LIBS=on -DBUILD_SHARED_LIBS=off"
    build_makefile_package "master" "lzo"
    build_makefile_package "v1.2.3" "zlib"
    build_cmake_package "v1.5.1" "zstd" "" "-DSTD_BUILD_STATIC=on -DZSTD_USE_STATIC_RUNTIME=on"
    build_cmake_package "1.1.9" "snappy" "" "-DSNAPPY_BUILD_TESTS=0 -DSNAPPY_BUILD_BENCHMARKS=0 "
    #默认按照在系统路径之下
    build_makefile_package "liburing-2.1" "liburing"
    build_cmake_package "20210528" "libdwarf" "" "-DBOOSTS_ROOT_DIR=${project_dir}/libs/boosts"
    #默认安装在系统路径之下
    build_makefile_package "libaio.0-3-107.1" "libaio"
    build_makefile_package "v1.6.2" "libunwind"
    build_makefile_package "release-2.1.8-stable" "libevent" "" "--disable-shared --enable-static --with-pic LDFLAGS=-L${project_dir}/libs/openssl/lib CPPFLAGS=-I${project_dir}/libs/openssl/include"

}
# libdwarf libaio libunwind
#source /opt/rh/devtoolset-10/enable
#scl enable devtoolset-9 bash
#build_boosts
#build_base_deps
build_makefile_package "v3.19.0" "protobuf" "" "--disable-shared --enable-static"

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

cmake_params=""
cmake_prefix_path=""
cmake_inc=""
cmake_libs=""

for key in ${!libs[@]};do
    cmake_params="-D${key}_ROOT_DIR=${libs[${key}]} ${cmake_params}"
    cmake_prefix_path="${libs[${key}]};${cmake_prefix_path}"
    cmake_inc="${libs[${key}]}/include:${cmake_inc}"
    cmake_libs="${libs[${key}]}/lib:${libs[${key}]}/lib64:${cmake_libs}"
done

#build_cmake_package "v2021.05.10.00" "folly" "" "-DCMAKE_CXX_STANDARD=20 -DCMAKE_CXX_FLAGS=-fpermissive -DCMAKE_LIBRARY_ARCHITECTURE=x86_64 ${cmake_params} -DBUILD_TESTS=OFF -DVELOX_BUILD_TESTING=OFF  -DCMAKE_PREFIX_PATH=${cmake_prefix_path} -DCMAKE_INCLUDE_PATH=${cmake_inc} -DCMAKE_LIBRARY_PATH=${cmake_libs}"
## prestocpp 依赖
#build_cmake_package "v2021.12.27.00" "fizz" "fizz" -DCMAKE_BUILD_TYPE=RelWithDebInfo
#build_cmake_package "v2021.12.27.00" "wangle" "wangle" -DOPENSSL_ROOT_DIR=$project_dir/libs/openssl
#build_cmake_package "v2021.12.27.00" "proxygen" "" "-DCMAKE_PREFIX_PATH=$project_dir/libs/openssl;$project_dir/libs/fmt;$project_dir/libs/folly;$project_dir/libs/zstd"
