#!/bin/bash

BASE=/home/jack/build
INSTALL=/opt/petsc

REMOTE=firedrake
PETSC_BASE_DIR=$BASE/${REMOTE}-petsc
cd $PETSC_BASE_DIR

rm -rf \
    $INSTALL/$REMOTE/cuda-*

git checkout firedrake
git pull

# Build all the different PETSc configurations
_ARCH=cuda
# NVCC bug:
export NVCC_PREPEND_FLAGS='-ccbin /opt/cuda/bin'
for BUILD in debug opt
do
    ./my_builds/configure_prefix.py \
        --prefix=$INSTALL/$REMOTE/$_ARCH-$BUILD \
        ${_ARCH}-${BUILD}
    make all-local
    make install
    ln -s /share/$REMOTE-petsc/src $INSTALL/$REMOTE/$_ARCH-$BUILD/
done
