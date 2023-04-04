#!/usr/bin/python3
import sys
import os

from argparse import ArgumentParser

parser = ArgumentParser('Custom wrapper from PETSc configure')
parser.add_argument(
    'name',
    type=str,
    help='Name of preset custom configuration')

args, unknown = parser.parse_known_args()

base_options = [
    f'--prefix=/opt/petsc/{args.name}',
    '--with-c2html=0',
    '--with-cxx-dialext=C++11',
    '--with-fortran-bindings=0',
    '--with-mpi-dir=/opt/mpich',
    f'PETSC_ARCH={args.name}',
  ]

debug = ['--with-debugging=1']
opt = [
    '--COPTFLAGS=-O3 -march=native -mtune=native',
    '--CXXOPTFLAGS=-O3 -march=native -mtune=native',
    '--FOPTFLAGS=-O3 -march=native -mtune=native',
    '--with-debugging=0',
]

# Firedrake
# Specify --download-eigen=$EIGEN_TGZ outside to avoid repeated downloading
minimal = [
    '--download-ptscotch',
    '--download-mumps',
    '--download-superlu_dist',
    '--download-scalapack',
    '--download-chaco',
    '--download-hdf5'
]

minimal_not_complex = ['--download-hypre']

firedrake = minimal + [
    '--download-suitesparse',
    '--download-hwloc',
    '--download-netcdf',
    '--download-pnetcdf',
    '--download-pastix',
    '--download-metis',
    '--with-zlib'
]

firedrake_not_complex = minimal_not_complex + ['--download-ml']

firedrake_complex = ['--with-scalar-type=complex']

custom_conf = {
    'main-vanilla-debug': debug,
    'main-vanilla-opt': opt,
    'firedrake-minimal-debug': debug + minimal + minimal_not_complex,
    'firedrake-minimal-opt': opt + minimal + minimal_not_complex,
    'firedrake-debug': debug + firedrake + firedrake_not_complex,
    'firedrake-opt': opt + firedrake + firedrake_not_complex,
    'firedrake-complex-minimal-debug': debug + minimal + firedrake_complex,
    'firedrake-complex-minimal-opt': opt + minimal + firedrake_complex,
    'firedrake-complex-debug': debug + firedrake + firedrake_complex,
    'firedrake-complex-opt': opt + firedrake + firedrake_complex,
    'sv-build-debug': debug + firedrake,
    'sv-build-opt': opt + firedrake,
    'custom': unknown,
    'test': unknown
}


if __name__ == '__main__':
  sys.path.insert(0, os.path.abspath('config'))
  import configure

  print('Congiguring install for', base_options[0])
  configure_options = base_options + custom_conf[args.name]
  configure.petsc_configure(configure_options)
