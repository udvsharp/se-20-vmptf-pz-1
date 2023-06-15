#! /usr/bin/python3

from distutils.core import Extension, setup
from Cython.Build import cythonize
import os

current_dir = os.path.dirname(__file__)
relative_path = 'module.pyx'
module_path = os.path.join(current_dir, relative_path)

ext = Extension(name="module", sources=[module_path])
setup(ext_modules=cythonize(ext))

