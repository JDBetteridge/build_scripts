#!/bin/bash
# INSTALL_DIR=/opt/petsc
# See ./mybuilds/configure.py for detailed options
# Initially need to:
# curl -OL https://github.com/eigenteam/eigen-git-mirror/archive/3.3.3.tar.gz
# mv 3.3.3.tar.gz eigen-3.3.3.tgz
# git clone git@gitlab.com:petsc/petsc.git
# git remote add firedrake git@github.com:firedrakeproject/petsc.git
# git fetch --all
# git checkout -b firedrake firedrake/firedrake

PETSC_DIR=/home/jack/build/petsc
cd $PETSC_DIR
git fetch --all

# Pre-cleanup
rm -rf /opt/petsc/firedrake-* /opt/petsc/main-vanilla-*
rm -rf $PETSC_DIR/firedrake-* $PETSC_DIR/main-vanilla-*


# PETSc main
git checkout main
git pull
for PETSC_ARCH in main-vanilla-debug main-vanilla-opt
do
    my_builds/configure.py --force $PETSC_ARCH
    make PETSC_DIR=$PETSC_DIR PETSC_ARCH=$PETSC_ARCH all
    make PETSC_DIR=$PETSC_DIR PETSC_ARCH=$PETSC_ARCH install
done


# PETSc Firedrake branch
# --show-petsc-configure-options --minimal-petsc {0} --complex --petsc-int-type=int64
export EIGEN_TGZ=/home/jack/build/eigen-3.3.3.tgz
git checkout firedrake
git pull
for BUILD in debug opt
do
    for PETSC_ARCH in firedrake-minimal firedrake firedrake-complex # firedrake-int64
    do
        my_builds/configure.py --force $PETSC_ARCH-$BUILD --download-eigen=$EIGEN_TGZ
        make PETSC_DIR=$PETSC_DIR PETSC_ARCH=$PETSC_ARCH-$BUILD all-local
        make PETSC_DIR=$PETSC_DIR PETSC_ARCH=$PETSC_ARCH-$BUILD install
    done
done
