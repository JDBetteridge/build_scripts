#!/bin/bash
# Initially need to:
# git clone git@github.com:python/cpython.git
# cd cpython
# git fetch --all
# for VERSION in v3.8.16 v3.9.16 v3.10.10 v3.11.2
# do
#     git checkout -b $VERSION tags/$VERSION
# done
# sudo mkdir -p /opt/python
# sudo chown jack /opt/python

export INSTALL_PATH=/opt/python

PYTHON_DIR=/home/jack/build/cpython
cd $PYTHON_DIR

for VERSION in v3.8.16 v3.9.16 v3.10.10 v3.11.2
do
    git checkout $VERSION
    git clean -fdx

    PY_LDFLAGS="-Wl,-rpath=$INSTALL_PATH/$VERSION/lib -L$INSTALL_PATH/$VERSION/lib"
    OPT="--enable-optimizations"
    ./configure --prefix=$INSTALL_PATH/$VERSION \
        --with-ensurepip \
        --enable-shared \
        $OPT \
        LDFLAGS="$PY_LDFLAGS"
    make -j32
    make -j32 install
done

git checkout main
git clean -fdx
