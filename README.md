Cirno's Perfect Math Library
====

[![Build Status](https://travis-ci.org/excessive/cpml.svg?branch=master)](https://travis-ci.org/excessive/cpml)
[![Coverage Status](https://coveralls.io/repos/github/excessive/cpml/badge.svg?branch=master)](https://coveralls.io/github/excessive/cpml?branch=master)

Various useful bits of game math. 3D line intersections, ray casting, vectors, matrices, quaternions, etc.

Intended to be used with LuaJIT and LÖVE (this is the backbone of LÖVE3D).

Online documentation can be found [here](http://excessive.github.io/cpml/) or you can generate them yourself using `ldoc -c doc/config.ld -o index .`

# Installation
Clone the repository and require it, or if you prefer luarocks: `$ luarocks install --server=http://luarocks.org/dev cpml`. Add `--tree=whatever` for a local install.

# Versions

This library has a major compatibility break at version 1.0. Up to version 0.10, composition a*b means "apply b, then a" for quaternions and "apply a, then b" for matrices. Now as of version 1.0, the two are consistent and matrix a*b means "apply b, then a".
