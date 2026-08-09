#!/bin/bash
# remove_function.sh - Remove a Qt slot from all locations
# Usage: ./remove_function.sh "on_btnSave_clicked"

set -e

FUNC_NAME="$1"
if [ -z "$FUNC_NAME" ]; then
    echo "Usage: $0 \"functionName\""
    echo "Example: $0 \"on_btnSave_clicked\""
    exit 1
fi

PROJECT_DIR="$(dirname "$0")/src"
cd "$PROJECT_DIR"

echo "Removing: $FUNC_NAME"

# 1. Remove from header (.h)
echo "  Checking header files..."
for h_file in *.h; do
    if grep -q "$FUNC_NAME" "$h_file"; then
        echo "    Found in $h_file - removing declaration"
        sed -i "/$FUNC_NAME/d" "$h_file"
    fi
done

# 2. Remove from source (.cpp)
echo "  Checking source files..."
for cpp_file in *.cpp; do
    if grep -q "$FUNC_NAME" "$cpp_file"; then
        echo "    Found in $cpp_file - removing definition"
        # Remove function block (from declaration to closing brace)
        sed -i "/void [A-Za-z_]*::${FUNC_NAME}/,/^}/d" "$cpp_file"
    fi
done

# 3. Check UI file
echo "  Checking UI file..."
ui_file=$(ls *.ui 2>/dev/null | head -1)
if [ -n "$ui_file" ]; then
    # Extract widget name from function name (on_widgetName_signal)
    widget_name=$(echo "$FUNC_NAME" | sed 's/^on_\(.*\)_clicked$/\1/' | sed 's/^on_\(.*\)_triggered$/\1/')
    if grep -q "name=\"$widget_name\"" "$ui_file"; then
        echo "    WARNING: Widget '$widget_name' exists in $ui_file"
        echo "    You may want to remove the widget from Qt Designer"
    fi
fi

# 4. Clean and rebuild
echo "  Cleaning build..."
cd build 2>/dev/null || mkdir -p build && cd build
make clean 2>/dev/null || true
cd ..
/usr/lib/qt6/bin/qmake .
cd build
make -j4

echo "Done! Check for any remaining warnings."