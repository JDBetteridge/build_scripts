#!/bin/bash
# Initially need to:
# for PYTHON in /opt/python/**/bin/python3
# do
#     $PYTHON -m venv py3$($PYTHON -c "import sys; print(sys.version_info.minor)")
# done

export PETSC_DIR=/opt/petsc/firedrake
export PETSC_ARCH=full-opt
export LDFLAGS="-Wl,-rpath,/opt/mpich/lib -L/opt/mpich/lib"

rm -rf \
    $PETSC_DIR/src/binding/petsc4py/dist \
    $PETSC_DIR/src/binding/petsc4py/build

for PYENV in py38 py39 py310 py311
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
    cd $PETSC_DIR/src/binding/petsc4py
    $VIRTUAL_ENV/bin/python setup.py bdist_wheel
    deactivate
    cd /home/jack/build
done

# debug
export PETSC_DIR=/opt/petsc/firedrake
export PETSC_ARCH=full-debug
export LDFLAGS="-Wl,-rpath,/opt/mpich/lib -L/opt/mpich/lib"

for PYENV in py38 py39 py310 py311
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
    cd $PETSC_DIR/src/binding/petsc4py
    mkdir -p dist/debug
    $VIRTUAL_ENV/bin/python setup.py bdist_wheel -d dist/debug -p $PETSC_ARCH
    deactivate
    cd /home/jack/build
done

# Complex
export PETSC_DIR=/opt/petsc/firedrake
export PETSC_ARCH=complex-opt
export LDFLAGS="-Wl,-rpath,/opt/mpich/lib -L/opt/mpich/lib"

for PYENV in py38 py39 py310 py311
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
    cd $PETSC_DIR/src/binding/petsc4py
    mkdir -p dist/complex
    $VIRTUAL_ENV/bin/python setup.py bdist_wheel -d dist/complex -p $PETSC_ARCH
    deactivate
    cd /home/jack/build
done
