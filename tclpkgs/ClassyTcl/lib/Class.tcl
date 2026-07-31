#
# ClassyTcl
# --------- Peter De Rijk
#
# Class
#
# Create the base class Class, the work namespace ::Class
# and all supplementary commands 
#
# ----------------------------------------------------------------------
#doc Class title {
#Class
#} descr {
# The class named Class forms the basis of the 
# <a href="classy_object_system.html">ClassyTcl object system</a>. It is the
# superclass of all classes and object in ClassyTcl.
# Class provides the functionality to produce classes and objects. Class 
# will normally not be used by itself to create objects.
#}
#}

#
# ------------------------------------------------------
# Create the work namespace class
# ------------------------------------------------------
#

if {"[info commands ::Class::reinit]" != ""} {
	set noc 0
	::Class::reinit
} else {
	set noc 1
	source [file join $Class::dir lib Class-tcl.tcl]
}
