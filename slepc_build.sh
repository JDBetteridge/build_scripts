#!/bin/bash
# INSTALL_DIR=/opt/slepc
#
# git clone git@gitlab.com:slepc/slepc.git upstream-slepc
# or
# git clone https://gitlab.com/slepc/slepc.git upstream-slepc
# cd upstream-slepc
# git fetch --all
# cd ..
#
# git clone git@github.com:firedrakeproject/slepc.git firedrake-slepc
# cd firedrake-slepc
# git fetch --all
# cd ..
#
# sudo mkdir -p /opt/slepc
# sudo chown jack /opt/slepc
# mkdir /opt/slepc/upstream
# mkdir /opt/slepc/firedrake

## sudo mkdir -p /share/upstream-slepc /share/firedrake-slepc
## /etc/fstab:
## # SLEPc source
## /home/jack/build/upstream-slepc   /share/upstream-slepc   none  bind 0 0
## /home/jack/build/firedrake-slepc  /share/firedrake-slepc  none  bind 0 0
## sudo systemctl daemon-reload
## sudo mount upstream-slepc
## sudo mount firedrake-slepc
## ln -s /share/upstream-slepc/src /opt/slepc/upstream/src
## ln -s /share/upstream-slepc/include /opt/slepc/upstream/include
## ln -s /share/firedrake-slepc/src /opt/slepc/firedrake/src
## ln -s /share/firedrake-slepc/include /opt/slepc/firedrake/include

BASE=/home/jack/build
INSTALL=/opt/slepc

##################
# SLEPc upstream #
##################
REMOTE=upstream
PETSC_DIR=$BASE/${REMOTE}-petsc
SLEPC_DIR=$BASE/${REMOTE}-slepc
cd $SLEPC_DIR

# Cleanup
rm -rf $INSTALL/$REMOTE/vanilla-*
rm -rf $SLEPC_DIR/vanilla-*

# rebuild
git fetch --all
git checkout main
git pull
for PETSC_ARCH in vanilla-debug vanilla-opt
do
    env PETSC_DIR=$PETSC_DIR PETSC_ARCH=$PETSC_ARCH \
        ./configure \
            --prefix=$INSTALL/$REMOTE/$PETSC_ARCH
    make SLEPC_DIR=$SLEPC_DIR PETSC_DIR=$PETSC_DIR PETSC_ARCH=$PETSC_ARCH all
    make SLEPC_DIR=$SLEPC_DIR PETSC_DIR=$PETSC_DIR PETSC_ARCH=$PETSC_ARCH install
done

##########################
# SLEPc Firedrake branch #
##########################
REMOTE=firedrake
PETSC_DIR=$BASE/${REMOTE}-petsc
SLEPC_DIR=$BASE/${REMOTE}-slepc
cd $SLEPC_DIR

# Cleanup
rm -rf $INSTALL/$REMOTE/minimal-* $INSTALL/$REMOTE/full-* $INSTALL/$REMOTE/complex-*
rm -rf $SLEPC_DIR/minimal-* $SLEPC_DIR/full-* $SLEPC_DIR/complex-*

git checkout firedrake
git pull
for BUILD in debug opt
do
    for PETSC_ARCH in minimal full complex # int64
    do
        env PETSC_DIR=$PETSC_DIR PETSC_ARCH=$PETSC_ARCH-$BUILD \
            ./configure \
                --prefix=$INSTALL/$REMOTE/$PETSC_ARCH-$BUILD
        make SLEPC_DIR=$SLEPC_DIR PETSC_DIR=$PETSC_DIR PETSC_ARCH=$PETSC_ARCH-$BUILD all-local
        make SLEPC_DIR=$SLEPC_DIR PETSC_DIR=$PETSC_DIR PETSC_ARCH=$PETSC_ARCH-$BUILD install
    done
done
