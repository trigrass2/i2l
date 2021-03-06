# i2l - Portable I2L interpreter in C

Copyright 2016 Eric Smith <spacewar@gmail.com>

i2l development is hosted at the
[i2l Github repository](https://github.com/brouhaha/i2l/).


## Introduction

Developed starting in 1976,
the [XPL0 programming language](http://www.xpl0.org/)
was originally compiled to I2L bytecode, similar to P-code, which was
then interpreted by an I2L interpreter, typically written in assembly
language.  In the early years, XPL0 was most commonly used on
6502-based microcomputers, including the Apple II, though I2L
interpreters were also written for the 8080/Z80 and 8088.  More recent
XPL0 compilers generate native code.

This I2L interpreter is written in C and is intended to be fairly
portable. It is intended to execute I2L code generated by the XPL V4B
or V4D compilers.  There are stubs for supporting I2L code generated
by the V5.6D compiler, which added floating point support.

This I2L interpreter does not support the intrinsics specfic to the
Apple II, which include graphics operations. It is intended to be
suitable for programs which use the text console and disk files
for I/O.


## Status

As of 2016-11-14, many features have not been tested. The prime demo
works, but the xplv4d compiler does not.


## Usage

The i2l interpreter expects as an argument the filename of an
I2L intermediate code file.

Examples:

* `i2l demo/prime.i2l`

  Runs the "prime" demo program.

* `i2l demo/prime.i2l --trace prime.trace`

  Runs the "prime" demo program slowly, while writing a trace of
  the I2L execution to prime.trace.


## License information

This program is free software: you can redistribute it and/or modify
it under the terms of version 3 of the GNU General Public License
as published by the Free Software Foundation.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
