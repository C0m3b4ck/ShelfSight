#!/bin/sh
# Launch the vTcl 8.6 drag-and-drop GUI builder (vendored).
# Usage: ./vtcl.sh                (opens the builder)
#        ./vtcl.sh app.tcl        (open a project/app in the builder)
DIR="$(cd "$(dirname "$0")" && pwd)"
export VTCL_HOME="$DIR/vtcl"
exec wish "$DIR/vtcl/vtcl.tcl" "$@"
