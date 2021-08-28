#!/bin/bash
# Do a build of boost using the boost infra.
# Libs go into build/boost/lib
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SSVIM_BUILD_DIR=$DIR/build

# Headers to /vendor/boost/include
# Libs to /vendor/boost/lib
BOOST_PREFIX=$SSVIM_BUILD_DIR/vendor/boost/
BOOST_LIB_DIR=$SSVIM_BUILD_DIR/vendor/boost/lib/
BOOST_LIB_ARRAY=("libboost_coroutine.a" "libboost_context.a" "libboost_filesystem.a" "libboost_program_options.a" "libboost_system.a" "libboost_thread.a")
LIB_COUNT=6

boost_lib_check() {
    if [ -d $BOOST_LIB_DIR ]; then
        for LIB in ${BOOST_LIB_ARRAY[@]}
        do
            FILE="${BOOST_LIB_DIR}/${LIB}"
            if [ -f $FILE ]; then
                COUNT=$((COUNT + 1))
            fi
        done
    fi

    if [[ $LIB_COUNT == $COUNT ]] && [[ -z $CI ]]; then
        echo "boost libraries already exist! exiting."
        exit 0
    fi
}
boost_lib_check
mkdir -p $BOOST_LIB_DIR

# Wants to build from here.
cd $DIR/vendor/boost
./bootstrap.sh --prefix=$BOOST_PREFIX \
    --libdir=$BOOST_LIB_DIR --without-icu

./b2 --prefix=$BOOST_PREFIX \
    --libdir=$BOOST_LIB_DIR \
    --user-config=user-config.jam \
    -d2 \
    -j4 \
    --layout-tagged install \
    threading=multi \
    link=static \
    cxxflags="-std=c++14 -stdlib=libc++" linkflags="-stdlib=libc++ -std=c++14"

