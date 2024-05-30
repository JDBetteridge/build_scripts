#!/usr/bin/python3
import sys
import os

from argparse import ArgumentParser
from pprint import pprint

parser = ArgumentParser('Custom wrapper from PETSc configure')
parser.add_argument(
    'name',
    type=str,
    help='Name of preset custom configuration'
)
parser.add_argument(
    '--package-dir',
    type=str,
    default='.',
    help='Path to an external package installation'
)

args, unknown = parser.parse_known_args()

base_options = [
    '--with-bison',
    '--with-c2html=0',
    '--with-cxx-dialext=C++11',
    '--with-flex',
    '--with-fortran-bindings=0',
    '--with-mpi-dir=/opt/mpich',
    '--with-zlib',
]

debug = ['--with-debugging=1']
opt = [
    '--COPTFLAGS=-O3 -march=native -mtune=native',
    '--CXXOPTFLAGS=-O3 -march=native -mtune=native',
    '--FOPTFLAGS=-O3 -march=native -mtune=native',
    '--with-debugging=0',
]

# All pacakges
packages = [
    '--download-hdf5',
    '--download-hwloc',
    '--download-hypre',
    '--download-metis',
    '--download-mumps',
    '--download-netcdf',
    '--download-pastix',
    '--download-pnetcdf',
    '--download-ptscotch',
    '--download-scalapack',
    '--download-suitesparse',
    '--download-superlu_dist',
]

package_dir = args.package_dir

# Firedrake
minimal = [
    f'--with-hdf5-dir={package_dir}',
    f'--with-mumps-dir={package_dir}',
    f'--with-ptscotch-dir={package_dir}',
    f'--with-scalapack-dir={package_dir}',
    f'--with-superlu_dist-dir={package_dir}',
]

minimal_not_complex = [f'--with-hypre-dir={package_dir}']

firedrake = minimal + [
    f'--with-hwloc-dir={package_dir}',
    f'--with-metis-dir={package_dir}',
    f'--with-netcdf-dir={package_dir}',
    f'--with-pastix-dir={package_dir}',
    f'--with-pnetcdf-dir={package_dir}',
    f'--with-suitesparse-dir={package_dir}',
]

firedrake_complex = ['--with-scalar-type=complex']

# Cuda build of PETSc
cuda_base_options = [
    '--with-bison',
    '--with-c2html=0',
    '--with-cuda-dir=/opt/cuda',
    '--with-cudac=/opt/cuda/bin/nvcc',
    '--with-cxx-dialext=C++11',
    '--with-flex',
    '--with-fortran-bindings=0',
    '--with-mpi-dir=/opt/mpich-cuda',
    '--with-zlib',
]

cuda_packages = [
    '--download-hdf5',
    '--download-hwloc',
    '--download-hypre',
    '--download-mumps',
    '--download-ptscotch',
    '--download-scalapack',
    '--download-superlu_dist',
]

custom_conf = {
    'vanilla-debug': base_options + debug,
    'vanilla-opt': base_options + opt,
    'packages': base_options + opt + packages,
    'minimal-debug': base_options + debug + minimal + minimal_not_complex,
    'minimal-opt': base_options + opt + minimal + minimal_not_complex,
    'full-debug': base_options + debug + firedrake + minimal_not_complex,
    'full-opt': base_options + opt + firedrake + minimal_not_complex,
    'complex-minimal-debug': base_options + debug + minimal + firedrake_complex,
    'complex-minimal-opt': base_options + opt + minimal + firedrake_complex,
    'complex-debug': base_options + debug + firedrake + firedrake_complex,
    'complex-opt': base_options + opt + firedrake + firedrake_complex,
    'cuda-debug': cuda_base_options + debug + cuda_packages,
    'cuda-opt': cuda_base_options + opt + cuda_packages,
    'custom': base_options + unknown,
    'test': base_options + unknown
}


if __name__ == '__main__':
  sys.path.insert(0, os.path.abspath('config'))
  import configure

  configure_options = custom_conf[args.name]
  print('Configuring install for', args.name)
  print('which uses the following configuration flags:')
  print('\t' + '\n\t'.join(configure_options))
  print(f'Using the package directory {package_dir =}')
  configure.petsc_configure(configure_options)
