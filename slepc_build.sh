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
PETSC_BASE_DIR=/opt/petsc/${REMOTE}
SLEPC_DIR=$BASE/${REMOTE}-slepc
cd $SLEPC_DIR

# Cleanup
rm -rf $INSTALL/$REMOTE/vanilla-*
rm -rf $SLEPC_DIR/installed-arch-*

# rebuild
git fetch --all
git checkout main
git pull
# Don't use PETSC_ARCH for prefix builds (https://slepc.upv.es/documentation/slepc.pdf)
for _ARCH in vanilla-debug vanilla-opt
do
    env PETSC_DIR=$PETSC_BASE_DIR/$_ARCH \
        ./configure \
            --prefix=$INSTALL/$REMOTE/$_ARCH
    make SLEPC_DIR=$SLEPC_DIR PETSC_DIR=$PETSC_BASE_DIR/$_ARCH all
    make SLEPC_DIR=$SLEPC_DIR PETSC_DIR=$PETSC_BASE_DIR/$_ARCH install
    ln -s /share/${REMOTE}-slepc/src $INSTALL/$REMOTE/$_ARCH-$BUILD/src
done

##########################
# SLEPc Firedrake branch #
##########################
REMOTE=firedrake
PETSC_BASE_DIR=/opt/petsc/${REMOTE}
SLEPC_DIR=$BASE/${REMOTE}-slepc
cd $SLEPC_DIR

# Cleanup
rm -rf $INSTALL/$REMOTE/minimal-* $INSTALL/$REMOTE/full-* $INSTALL/$REMOTE/complex-*
rm -rf $SLEPC_DIR/installed-arch-*

git checkout firedrake
git pull
for BUILD in debug opt
do
    # Don't use PETSC_ARCH for prefix builds (https://slepc.upv.es/documentation/slepc.pdf)
    for _ARCH in full complex # minimal int64
    do
        # Hopefully this nasty hack will go away when the PETSc branch is moved forwards
        mv -n $PETSC_BASE_DIR/$_ARCH-$BUILD/share/petsc/examples/config/gmakegen.py \
            $PETSC_BASE_DIR/$_ARCH-$BUILD/share/petsc/examples/config/gmakegen.py.backup
        cp /opt/petsc/upstream/vanilla-opt/share/petsc/examples/config/gmakegen.py \
            $PETSC_BASE_DIR/$_ARCH-$BUILD/share/petsc/examples/config/gmakegen.py
        env PETSC_DIR=$PETSC_BASE_DIR/$_ARCH-$BUILD \
            ./configure \
                --prefix=$INSTALL/$REMOTE/$_ARCH-$BUILD
        make SLEPC_DIR=$SLEPC_DIR PETSC_DIR=$PETSC_BASE_DIR/$_ARCH-$BUILD all-local
        make SLEPC_DIR=$SLEPC_DIR PETSC_DIR=$PETSC_BASE_DIR/$_ARCH-$BUILD install
        ln -s /share/${REMOTE}-slepc/src $INSTALL/$REMOTE/$_ARCH-$BUILD/src
    done
done
