ExtraL
======
extra commands for Tcl
by Peter De Rijk (Universiteit Antwerpen) 

What is ExtraL
--------------

Extral is a generally useful library which extends Tcl with a.o.:
* extral list manipulation commands
* extra string manipulation commands
* array manipulation
* map
* atexit
* tempfile
* filing commands
	
The name comes from the fact that ExtraL originally only contained
extra list processing commands to overcome some of the performance 
problems in Tcl when processing large lists. Later other commands
were added. With the advent of the Tcl byte compiler, the 
performance is not such a great issue any longer, but many of the list 
manipulation functions are still very convenient, and some 
of those that were now rewritten using the object system in C are 
still faster. 
Most functions are now also available in Tcl-only form as well. Using 
the C code just gives a speedup.

Documentation is available on
[https://derijkp.github.io/Extral/index.html](https://derijkp.github.io/Extral/index.html)
(and in the docs directory). For some of the commands, you can also find
out a lot by checking the testing suite in the directory tests.

Installation
------------
You should be able to obtain the latest version of ExtraL on github at
https://github.com/derijkp/Extral

### Binary packages

A portable binary ExtraL package can be "installed" by downloading it from github

* [Extral-2.1.0-Linux-x86_64.tar.gz](https://github.com/derijkp/Extral/releases/download/2.1.0/Extral-2.1.0-Linux-x86_64.tar.gz) (Linux)
* [Extral-2.1.0-windows-x86_64.tar.gz](https://github.com/derijkp/Extral/releases/download/2.1.0/Extral-2.1.0-windows-x86_64.tar.gz) (Windows)

and unpacking it where Tcl can find it. 

The command 
```
package require Extral
```
will load the package. A binary package does not necesarily contains
compiled code: If no compiled version (.so, .dll) is available, a 
Tcl-only version will be used. The compiled version is made in such a way
that it will also run on older Linux systems.

### From source: portable binary

Extral includes the build script to create these portable binaries.
It is based on Holy Build Box (https://github.com/phusion/holy-build-box)
which uses docker to provide a compatible build environment. Access
to docker is required for this.
This build expects a hbb install of dirtcl
(https://github.com/derijkp/dirtcl) on the system, so this has to be
installed first.
Then you can do the install using (in the Extral source directory):
```
./build/hbb_build_Extral.sh
```

You can also build the Windows version on Linux using this script (using crosscompilation):
```
./build/hbb_build_Extral.sh -arch win
```

### From Source: TEA

Extral follows TEA, and can be compiled using the normal configure/make workflow:
Compiled packages should be created using the following steps in the package directory:
(You can also build in any other directory, if you change the path to the configure command)
```
./configure
make
make install
```

The configure command has several options that can be examined using
```
./configure --help
```

During compilation, the Tcl sources must be available; if the Tcl source
directory is not a sibling of the Extral source directory, you will have to
specify its position by giving a parameter to the ./configure script:
```
./configure --with-tcl=DIR (where DIR is the Tcl source tree)
```
in the following description.

How to contact me
-----------------

Peter De Rijk
University of Antwerp
VIB department of Molecular Genetics
Universiteitsplein 1
B-2610 Antwerp

E-mail: Peter.DeRijk@uantwerpen.be

Legalities
----------

ExtraL is Copyright Peter De Rijk, University of Antwerp, 1995 The
following terms apply to all files associated with the software unless
explicitly disclaimed in individual files.

The author hereby grant permission to use, copy, modify, distribute,
and license this software and its documentation for any purpose, provided
that existing copyright notices are retained in all copies and that this
notice is included verbatim in any distributions. No written agreement,
license, or royalty fee is required for any of the authorized uses.
Modifications to this software may be copyrighted by their authors
and need not follow the licensing terms described here, provided that
the new terms are clearly indicated on the first page of each file where
they apply.

IN NO EVENT SHALL THE AUTHORS OR DISTRIBUTORS BE LIABLE TO ANY PARTY
FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
ARISING OUT OF THE USE OF THIS SOFTWARE, ITS DOCUMENTATION, OR ANY
DERIVATIVES THEREOF, EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.  THIS SOFTWARE
IS PROVIDED ON AN "AS IS" BASIS, AND THE AUTHORS AND DISTRIBUTORS HAVE
NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
MODIFICATIONS.
