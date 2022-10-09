# -*- coding: utf-8 -*-
from setuptools import find_packages, setup

setup(
    name="bumble_bot",
    package_dir={"": "src"},
    packages=find_packages(where="src"),
    version="0.1.0",
    description="Bumble bot",
    author="Sergei",
)
