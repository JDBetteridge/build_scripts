#!/bin/bash
# git clone git@github.com:firedrakeproject/petsc.git cuda-petsc
# mkdir /opt/petsc/cuda
# sudo mkdir -p /share/cuda-petsc
## Append to /etc/fstab:
## # PETSc source
## /home/jack/build/cuda-petsc   /share/cuda-petsc   none  bind 0 0
## sudo systemctl daemon-reload
## sudo mount cuda-petsc

BASE=/home/jack/build
INSTALL=/opt/petsc

REMOTE=cuda
PETSC_BASE_DIR=$BASE/${REMOTE}-petsc
cd $PETSC_BASE_DIR

rm -rf \
    $INSTALL/$REMOTE/cuda-*
rm -rf $PETSC_BASE_DIR/arch-*

git checkout firedrake
git pull

# Custom configure script
mkdir -p $PETSC_BASE_DIR/my_builds
cp $BASE/build_scripts/petsc_configure_prefix.py $PETSC_BASE_DIR/my_builds/configure_prefix.py

# Build all the different PETSc configurations
_ARCH=cuda
# NVCC bug:
# Potentially not needed anymore
# export NVCC_PREPEND_FLAGS='-ccbin /opt/cuda/bin'
for BUILD in debug opt
do
    ./my_builds/configure_prefix.py \
        --prefix=$INSTALL/$REMOTE/$_ARCH-$BUILD \
        ${_ARCH}-${BUILD}
    make all-local
    make install
    ln -s /share/$REMOTE-petsc/src $INSTALL/$REMOTE/$_ARCH-$BUILD/
done
