#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PS3="Choose architecture + OS: "
options=(
  "Linux x86"
  "Linux x86_64"
  "Windows XP+ x86"
  "Windows XP+ x86_64"
  "Windows Legacy (95,98,NT 4,Me,2000)"
  "Quit"
)

select opt in "${options[@]}"; do
  build_script=""
  compile_script=""

  case "$opt" in
    "Linux x86")
      build_script="$SCRIPT_DIR/main-src/fltk-1.3.11/build-linux-x86.sh"
      compile_script="$SCRIPT_DIR/main-src/compile-linux-x86.sh"
      ;;
    "Linux x86_64")
      build_script="$SCRIPT_DIR/main-src/fltk-1.3.11/build-linux-x86_x64.sh"
      compile_script="$SCRIPT_DIR/main-src/compile-linux-x86_x64.sh"
      ;;
    "Windows XP+ x86")
      build_script="$SCRIPT_DIR/main-src/fltk-1.3.11/build-winxpp_x86.sh"
      compile_script="$SCRIPT_DIR/main-src/compile-winxpp_x86.sh"
      ;;
    "Windows XP+ x86_64")
      build_script="$SCRIPT_DIR/main-src/fltk-1.3.11/build-winxpp_x86_64.sh"
      compile_script="$SCRIPT_DIR/main-src/compile-winxpp_x86_64.sh"
      ;;
    "Windows Legacy (95,98,NT 4,Me,2000)")
      build_script="$SCRIPT_DIR/main-src/fltk-1.3.11/build-windows-legacy.sh"
      compile_script="$SCRIPT_DIR/main-src/compile-windows-legacy.sh"
      ;;
    "Quit")
      exit 0
      ;;
    *)
      echo "Invalid choice: $REPLY"
      continue
      ;;
  esac

  echo "Running build:   $build_script"
  bash "$build_script"

  echo "Running compile: $compile_script"
  bash "$compile_script"

  break
done
