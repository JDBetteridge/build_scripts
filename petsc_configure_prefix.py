#!/usr/bin/python3
import sys
import os

from argparse import ArgumentParser

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
    f'PETSC_ARCH={args.name}',
  ]

debug = ['--with-debugging=1']
opt = [
    '--COPTFLAGS=-O3 -march=native -mtune=native',
    '--CXXOPTFLAGS=-O3 -march=native -mtune=native',
    '--FOPTFLAGS=-O3 -march=native -mtune=native',
    '--with-debugging=0',
]

# All pacakges
# Specify --download-eigen=$EIGEN_TGZ outside
packages = [
    '--download-chaco',
    '--download-hdf5',
    '--download-hwloc',
    '--download-hypre',
    '--download-metis',
    '--download-ml',
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
print(f'{package_dir =}')

# Firedrake
minimal = [
    f'--with-chaco-dir={package_dir}',
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

firedrake_not_complex = minimal_not_complex + [f'--with-ml-dir={package_dir}']

firedrake_complex = ['--with-scalar-type=complex']

custom_conf = {
    'vanilla-debug': debug,
    'vanilla-opt': opt,
    'packages': base_options + opt + packages,
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

  print('Congiguring install for', base_options[0])
  configure_options = base_options + custom_conf[args.name]
  configure.petsc_configure(configure_options)
