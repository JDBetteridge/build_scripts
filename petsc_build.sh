#!/bin/bash
# INSTALL_DIR=/opt/petsc
# See ./mybuilds/configure.py for detailed options
# Initially need to:
# curl -OL https://github.com/eigenteam/eigen-git-mirror/archive/3.3.3.tar.gz
# mv 3.3.3.tar.gz eigen-3.3.3.tgz
#
# # git clone git@gitlab.com:petsc/petsc.git
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

## mkdir -p /share/upstream-petsc /share/firedrake-petsc
## /etc/fstab:
## # PETSc source
## /home/jack/build/upstream-petsc   /share/upstream-petsc   none  bind 0 0
## /home/jack/build/firedrake-petsc  /share/firedrake-petsc  none  bind 0 0
## sudo systemctl daemon-reload
## ln -s /share/upstream-petsc/src /opt/petsc/upstream/src
## ln -s /share/upstream-petsc/include /opt/petsc/upstream/include
## ln -s /share/firedrake-petsc/src /opt/petsc/firedrake/src
## ln -s /share/firedrake-petsc/include /opt/petsc/firedrake/include


BASE=/home/jack/build
INSTALL=/opt/petsc

#~ ##################
#~ # PETSc upstream #
#~ ##################
#~ REMOTE=upstream
#~ PETSC_DIR=$BASE/${REMOTE}-petsc
#~ cd $PETSC_DIR

#~ # Cleanup
#~ rm -rf $INSTALL/$REMOTE/vanilla-*
#~ rm -rf $PETSC_DIR/vanilla-*

#~ # rebuild
#~ git fetch --all
#~ git checkout main
#~ git pull
#~ for PETSC_ARCH in vanilla-debug vanilla-opt
#~ do
    #~ my_builds/configure.py \
		#~ --force $PETSC_ARCH \
		#~ --prefix=$INSTALL/$REMOTE/$PETSC_ARCH
    #~ make PETSC_DIR=$PETSC_DIR PETSC_ARCH=$PETSC_ARCH all
    #~ make PETSC_DIR=$PETSC_DIR PETSC_ARCH=$PETSC_ARCH install
#~ done

##########################
# PETSc Firedrake branch #
##########################
REMOTE=firedrake
PETSC_DIR=$BASE/${REMOTE}-petsc
cd $PETSC_DIR

# Cleanup
rm -rf $INSTALL/$REMOTE/minimal-* $INSTALL/$REMOTE/full-* $INSTALL/$REMOTE/complex-*
rm -rf $PETSC_DIR/minimal-* $PETSC_DIR/full-* $PETSC_DIR/complex-* 

# --show-petsc-configure-options --minimal-petsc {0} --complex --petsc-int-type=int64
export EIGEN_TGZ=$BASE/eigen-3.3.3.tgz
git checkout firedrake
git pull
for BUILD in debug opt
do
    for PETSC_ARCH in minimal full complex # int64
    do
        my_builds/configure.py \
			--force $PETSC_ARCH-$BUILD \
			--download-eigen=$EIGEN_TGZ \
			--prefix=$INSTALL/$REMOTE/$PETSC_ARCH-$BUILD
        make PETSC_DIR=$PETSC_DIR PETSC_ARCH=$PETSC_ARCH-$BUILD all-local
        make PETSC_DIR=$PETSC_DIR PETSC_ARCH=$PETSC_ARCH-$BUILD install
    done
done
