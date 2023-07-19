#!/bin/bash
# INSTALL_DIR=/opt/petsc
# See ./mybuilds/petsc_configure.py for detailed options
# Initially need to:
# # git clone git@gitlab.com:petsc/petsc.git upstream-petsc
# # or
# git clone https://gitlab.com/petsc/petsc.git upstream-petsc
# cd upstream-petsc
# git fetch --all
# cd ..
#
# git clone git@github.com:firedrakeproject/petsc.git firedrake-petsc
# cd firedrake-petsc
# git fetch --all
# cd ..
#
# mkdir -p upstream-petsc/my_builds firedrake-petsc/my_builds
# cp build_scripts/petsc_configure.py upstream-petsc/my_builds/configure.py
# cp build_scripts/petsc_configure.py firedrake-petsc/my_builds/configure.py
# sudo mkdir -p /opt/petsc
# sudo chown jack /opt/petsc
# mkdir /opt/petsc/upstream
# mkdir /opt/petsc/firedrake

## mkdir -p /share/upstream-petsc /share/firedrake-petsc
## /etc/fstab:
## # PETSc source
## /home/jack/build/upstream-petsc   /share/upstream-petsc   none  bind 0 0
## /home/jack/build/firedrake-petsc  /share/firedrake-petsc  none  bind 0 0
## sudo systemctl daemon-reload
## sudo mount upstream-petsc
## sudo mount firedrake-petsc
## ln -s /share/upstream-petsc/src /opt/petsc/upstream/src
## ln -s /share/upstream-petsc/include /opt/petsc/upstream/include
## ln -s /share/firedrake-petsc/src /opt/petsc/firedrake/src
## ln -s /share/firedrake-petsc/include /opt/petsc/firedrake/include


BASE=/home/jack/build
INSTALL=/opt/petsc

##################
# PETSc upstream #
##################
REMOTE=upstream
PETSC_BASE_DIR=$BASE/${REMOTE}-petsc
cd $PETSC_BASE_DIR

# Cleanup
rm -rf $INSTALL/$REMOTE/vanilla-*
rm -rf $PETSC_BASE_DIR/arch-*

# rebuild
git fetch --all
git checkout main
git pull
# Don't use PETSC_ARCH for prefix builds (https://slepc.upv.es/documentation/slepc.pdf)
for _ARCH in vanilla-debug vanilla-opt
do
    my_builds/configure.py \
        --prefix=$INSTALL/$REMOTE/$_ARCH $_ARCH
    make PETSC_DIR=$PETSC_BASE_DIR/$_ARCH all
    make PETSC_DIR=$PETSC_BASE_DIR/$_ARCH install
done

##########################
# PETSc Firedrake branch #
##########################
REMOTE=firedrake
PETSC_BASE_DIR=$BASE/${REMOTE}-petsc
cd $PETSC_BASE_DIR

# Cleanup
rm -rf $INSTALL/$REMOTE/minimal-* $INSTALL/$REMOTE/full-* $INSTALL/$REMOTE/complex-*
rm -rf $PETSC_BASE_DIR/arch-*

# --show-petsc-configure-options --minimal-petsc {0} --complex --petsc-int-type=int64
git checkout firedrake
git pull
for BUILD in debug opt
do
    # Don't use PETSC_ARCH for prefix builds (https://slepc.upv.es/documentation/slepc.pdf)
    for _ARCH in full complex # minimal int64
    do
        my_builds/configure.py \
            --prefix=$INSTALL/$REMOTE/$_ARCH-$BUILD $_ARCH
        make PETSC_BASE_DIR=$PETSC_DIR/$_ARCH-$BUILD all-local
        make PETSC_BASE_DIR=$PETSC_DIR/$_ARCH-$BUILD install
    done
done
