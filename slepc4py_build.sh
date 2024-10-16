#!/bin/bash
# Initially need to:
# for PYTHON in /opt/python/**/bin/python3
# do
#     $PYTHON -m venv py3$($PYTHON -c "import sys; print(sys.version_info.minor)")
# done

# slepc4py source needs patching with
# `git apply slepc4py.patch` in SLEPc source directory

ALL_ENVS="py39 py310 py311 py312"

export PETSC_DIR=/opt/petsc/firedrake/full-opt
export SLEPC_DIR=/opt/slepc/firedrake/full-opt
export LDFLAGS="-Wl,-rpath,/opt/mpich/lib -L/opt/mpich/lib"

rm -rf \
    $SLEPC_DIR/src/binding/slepc4py/dist \
    $SLEPC_DIR/src/binding/slepc4py/build

for PYENV in $ALL_ENVS
do
    . $PYENV/bin/activate
    echo ================
    echo $PYENV
    $VIRTUAL_ENV/bin/python --version
    echo ================
    $VIRTUAL_ENV/bin/pip install -U pip
    $VIRTUAL_ENV/bin/pip install -U setuptools
    $VIRTUAL_ENV/bin/pip install -U wheel
    $VIRTUAL_ENV/bin/pip install -U cython
    $VIRTUAL_ENV/bin/pip install -U numpy
    VERSION_STRING=$(python -c "import sys; v=sys.version_info; print(f'cp{v.major}{v.minor}')")
    $VIRTUAL_ENV/bin/pip install \
        $(ls $PETSC_DIR/src/binding/petsc4py/dist/petsc4py-*${VERSION_STRING}-${VERSION_STRING}*.whl)
    cd $SLEPC_DIR/src/binding/slepc4py
    $VIRTUAL_ENV/bin/python setup.py bdist_wheel
    $VIRTUAL_ENV/bin/pip uninstall -y petsc4py
    deactivate
    cd /home/jack/build
done

# debug
export PETSC_DIR=/opt/petsc/firedrake/full-debug
export SLEPC_DIR=/opt/slepc/firedrake/full-debug
export LDFLAGS="-Wl,-rpath,/opt/mpich/lib -L/opt/mpich/lib"

for PYENV in $ALL_ENVS
do
    . $PYENV/bin/activate
    echo ================
    echo $PYENV
    $VIRTUAL_ENV/bin/python --version
    echo ================
    $VIRTUAL_ENV/bin/pip install -U pip
    $VIRTUAL_ENV/bin/pip install -U setuptools
    $VIRTUAL_ENV/bin/pip install -U wheel
    $VIRTUAL_ENV/bin/pip install -U cython
    $VIRTUAL_ENV/bin/pip install -U numpy
    VERSION_STRING=$(python -c "import sys; v=sys.version_info; print(f'cp{v.major}{v.minor}')")
    $VIRTUAL_ENV/bin/pip install \
        $(ls $PETSC_DIR/src/binding/petsc4py/dist/debug/petsc4py-*${VERSION_STRING}-${VERSION_STRING}*.whl)
    cd $SLEPC_DIR/src/binding/slepc4py
    mkdir -p dist/debug
    $VIRTUAL_ENV/bin/python setup.py bdist_wheel -d dist/debug
    $VIRTUAL_ENV/bin/pip uninstall -y petsc4py
    deactivate
    cd /home/jack/build
done

# Complex
export PETSC_DIR=/opt/petsc/firedrake/complex-opt
export SLEPC_DIR=/opt/slepc/firedrake/complex-opt
export LDFLAGS="-Wl,-rpath,/opt/mpich/lib -L/opt/mpich/lib"

for PYENV in $ALL_ENVS
do
    . $PYENV/bin/activate
    echo ================
    echo $PYENV
    $VIRTUAL_ENV/bin/python --version
    echo ================
    $VIRTUAL_ENV/bin/pip install -U pip
    $VIRTUAL_ENV/bin/pip install -U setuptools
    $VIRTUAL_ENV/bin/pip install -U wheel
    $VIRTUAL_ENV/bin/pip install -U cython
    $VIRTUAL_ENV/bin/pip install -U numpy
    VERSION_STRING=$(python -c "import sys; v=sys.version_info; print(f'cp{v.major}{v.minor}')")
    $VIRTUAL_ENV/bin/pip install \
        $(ls $PETSC_DIR/src/binding/petsc4py/dist/complex/petsc4py-*${VERSION_STRING}-${VERSION_STRING}*.whl)
    cd $SLEPC_DIR/src/binding/slepc4py
    mkdir -p dist/debug
    $VIRTUAL_ENV/bin/python setup.py bdist_wheel -d dist/complex
    $VIRTUAL_ENV/bin/pip uninstall -y petsc4py
    deactivate
    cd /home/jack/build
done
