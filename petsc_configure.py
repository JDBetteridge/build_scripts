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
    '--with-c2html=0',
    '--with-cxx-dialext=C++11',
    '--with-fortran-bindings=0',
    '--with-mpi-dir=/opt/mpich',
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
    'vanilla-debug': debug,
    'vanilla-opt': opt,
    'minimal-debug': debug + minimal + minimal_not_complex,
    'minimal-opt': opt + minimal + minimal_not_complex,
    'full-debug': debug + firedrake + firedrake_not_complex,
    'full-opt': opt + firedrake + firedrake_not_complex,
    'complex-minimal-debug': debug + minimal + firedrake_complex,
    'complex-minimal-opt': opt + minimal + firedrake_complex,
    'complex-debug': debug + firedrake + firedrake_complex,
    'complex-opt': opt + firedrake + firedrake_complex,
    'custom': unknown,
    'test': unknown
}


if __name__ == '__main__':
  sys.path.insert(0, os.path.abspath('config'))
  import configure

  print('Configuring install for', base_options[0])
  configure_options = base_options + custom_conf[args.name]
  configure.petsc_configure(configure_options)
