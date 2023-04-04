#!/bin/bash
# Initially need to:
# git clone git@github.com:python/cpython.git
# git fetch --all
# for VERSION in v3.7.12 v3.8.12 v3.9.7 v3.10.0 v3.10.8 v3.11.0
# do
#     git checkout -b $VERSION tags/$VERSION
# done

export INSTALL_PATH=/opt/python

PYTHON_DIR=/home/jack/build/cpython
cd $PYTHON_DIR

for VERSION in v3.7.12 v3.8.12 v3.9.7 v3.10.0 v3.10.8 v3.11.0
do
    git checkout $VERSION
    git clean -fdx

    PY_LDFLAGS="-Wl,-rpath=$INSTALL_PATH/$VERSION/lib -L$INSTALL_PATH/$VERSION/lib"
    if [ $VERSION != v3.7.12 ]; then
		OPT="--enable-optimizations"
	else
		# Python 3.7 optimisation tests take too long/hang
		OPT=""
	fi
    ./configure --prefix=$INSTALL_PATH/$VERSION \
        --with-ensurepip \
        --enable-shared \
        $OPT \
        LDFLAGS="$PY_LDFLAGS"
    make -j16
    make -j16 install
done

git checkout main
git clean -fdx
