ClassyTcl

Object system, widget set and GUI builder for Tcl
by Peter De Rijk (Universiteit Antwerpen)

What is ClassyTcl
-----------------

ClassyTcl is a dynamically loadable object system for Tcl. A 
Tcl-only as well as a C implementation 
is available. It also doesn't require patches to the Tcl core, so
keeping up with new releases should be easy. Performance is very
adequate. The C version is gives extra speed, and makes it possible
to implement some methods in C.

In contrast to other Tcl object systems for Tcl, it is not modeled after 
the object system designed for a completely different language such a C. 
IMHO, it better follows the Tcl philosophy. The system is simple, but 
flexible. Classes and objects are dynamic, and can easily be queried, 
changed and debugged at runtime.

more information on the ClassyTcl object system can be found in
https://derijkp.github.io/ClassyTcl/classy_object_system.html
The Class commands is described in 
https://derijkp.github.io/ClassyTcl/Class.html

Installation
------------
You should be able to obtain the latest version of ClassyTcl
via www on url https://github.com/derijkp/ClassyTcl

Binary packages

A binary ClassyTcl package can be "installed" by placing it where Tcl can find
it. A binary package does not necesarily contain compiled code: If no 
compiled version (.so, .dll) is available, a Tcl-only version will be used.

Sources

Compiled packages should be created using the following steps in the package directory:
(You can also build in any other directory, if you change the path to the configure command)
./configure
make
make install

The configure command has several options that can be examined using
/configure --help

You can make a portable Linux binary using the provided script (requires docker):
build/hbb_build_ClassyTcl.sh

Use
---

The ClassyTcl object systen can be used by putting the directories (after
unpacking) somewhere appropriate and using the command
package require Class
This will add one command (and a namespace) named
[Class](https://derijkp.github.io/ClassyTcl/Class.html), that forms the
basis of
[ClassyTcl](https://derijkp.github.io/ClassyTcl/classy_object_system.html).

Porting to other platforms
--------------------------
The Tcl version should work anywhere Tcl works. The Tcl version will
be used when no shared object file or dll is found. You can create
binaries for other Unix platforms using the following steps:
cd ClassyTcl/build
./configure
make
make install

The configure command has several options that can be examined using
./configure --help

Contributions
-------------

If you have fixed bugs, made some nice additions to ClassyTcl widgets, etc.,
you can send them to me, and I will consider incorporating them in new
releases.

How to contact me
-----------------

Peter De Rijk
VIB - UAntwerp Center for Molecular Neurology
University of Antwerp - CDE, Parking P4, Building V, Room V1.15
Universiteitsplein 1, B-2610 Antwerpen, Belgium

E-mail: Peter.DeRijk@uantwerpen.be

Legalities
----------

ClassyTcl is Copyright Peter De Rijk, University of Antwerp (UA), 2000. The
following terms apply to all files associated with the software unless
explicitly disclaimed in individual files.

The author hereby grant permission to use, copy, modify, distribute, and
license this software and its documentation for any purpose, provided that
existing copyright notices are retained in all copies and that this notice
is included verbatim in any distributions. No written agreement, license, or
royalty fee is required for any of the authorized uses. Modifications to
this software may be copyrighted by their authors and need not follow the
licensing terms described here, provided that the new terms are clearly
indicated on the first page of each file where they apply.

IN NO EVENT SHALL THE AUTHORS OR DISTRIBUTORS BE LIABLE TO ANY PARTY FOR
DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
OF THE USE OF THIS SOFTWARE, ITS DOCUMENTATION, OR ANY DERIVATIVES THEREOF,
EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT. THIS SOFTWARE IS
PROVIDED ON AN "AS IS" BASIS, AND THE AUTHORS AND DISTRIBUTORS HAVE NO
OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
MODIFICATIONS.

