#!/bin/bash

curl -O https://raw.githubusercontent.com/firedrakeproject/firedrake/master/scripts/firedrake-install

export NVCC_PREPEND_FLAGS='-ccbin /opt/cuda/bin'
export MPICH_DIR=/opt/mpich-cuda/bin
export PETSC_DIR=/opt/petsc/cuda/cuda-opt
export HDF5_DIR=$PETSC_DIR

/opt/python/v3.11.2/bin/python3 firedrake-install \
    --no-package-manager \
    --honour-petsc-dir \
    --mpicc=$MPICH_DIR/mpicc \
    --mpicxx=$MPICH_DIR/mpicxx \
    --mpif90=$MPICH_DIR/mpif90 \
    --mpiexec=$MPICH_DIR/mpiexec \
    --venv-name=firedrake_cuda
