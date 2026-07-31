#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::Frame
# ----------------------------------------------------------------------

# ------------------------------------------------------------------
#  Creation
# ------------------------------------------------------------------

Widget subclass Classy::Topframe

Classy::Topframe method init {args} {
	super init

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
}
