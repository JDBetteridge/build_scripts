#!/bin/bash
# INSTALL_DIR=/opt/firedrake
# Initially need to:
# curl -O https://raw.githubusercontent.com/firedrakeproject/firedrake/master/scripts/firedrake-install

mkdir -p /opt/firedrake
cd /opt/firedrake

curl -O https://raw.githubusercontent.com/firedrakeproject/firedrake/master/scripts/firedrake-install

export MPICH_DIR=/opt/mpich/bin
export HDF5_DIR=/opt/petsc/firedrake/packages
export PETSC_DIR=/opt/petsc/firedrake/full-opt
export SLEPC_DIR=/opt/slepc/firedrake/full-opt

/opt/python/v3.11.2/bin/python3 firedrake-install \
    --no-package-manager \
    --honour-petsc-dir \
    --mpicc=$MPICH_DIR/mpicc \
    --mpicxx=$MPICH_DIR/mpicxx \
    --mpif90=$MPICH_DIR/mpif90 \
    --mpiexec=$MPICH_DIR/mpiexec \
    --venv-name=firedrake_py311_opt
