# Tcl package index file, version 1.0
# This file is sourced either when an application starts up or
# by a "package unknown" script.  It invokes the
# "package ifneeded" command to set up package-related
# information so that packages will be loaded automatically
# in response to "package require" commands.  When this
# script is sourced, the variable $dir must contain the
# full path name of this file's directory.

# $Format: "package ifneeded ClassyTk $ProjectMajorVersion$.$ProjectMinorVersion$ \\"$
package ifneeded ClassyTk 1.1 \
[subst -nocommands {
	namespace eval ::Classy {}
	set ::Classy::dir [list $dir]
	set ::Classy::script [info script]
	source [file join [list $dir] lib init.tcl]
}]
