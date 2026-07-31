# Initialisation of the Extral package
#
# Copyright (c) 1996 Peter De Rijk
#
# See the file "README.txt" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# =============================================================

namespace eval Extral {}

# $Format: "set ::Extral::version $ProjectMajorVersion$.$ProjectMinorVersion$"$
set ::Extral::version 2.1
# $Format: "set ::Extral::patchlevel $ProjectPatchLevel$"$
set ::Extral::patchlevel 0

package provide Extral $::Extral::version

package require pkgtools
pkgtools::init $Extral::dir Extral list_pop [file join $Extral::dir libnoc usenoc.tcl]
set Extral::noc [get noc 0]

#
# The lib dir contains the Tcl code defining the public Extral 
# functions. The lib dir is added to the auto_path so that
# these functions will be loaded on demand.
#

lappend auto_path [file join ${Extral::dir} lib]

source [file join ${Extral::dir} lib atexit.tcl]
source [file join ${Extral::dir} lib always.tcl]
# gives problems with 8.4
# Extral::compat
