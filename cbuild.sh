#!/bin/sh
# ClassyTk GUI builder launcher.
# Usage: ./cbuild.sh <appname>   (creates ./<appname>/ from the ClassyTk template)
DIR="$(cd "$(dirname "$0")" && pwd)"
export TCLLIBPATH="$DIR/tclpkgs"
exec wish "$DIR/tclpkgs/ClassyTk/bin/cbuild" "$@"
