# REMOVING UNWANTED FUNCTIONS - CHECKLIST

When removing a function (slot) from a Qt project, check ALL these locations:

## 1. Header File (.h)
- `class MyClass : public QMainWindow { ... }`
- Find the function declaration in `private slots:` section
- Remove the line: `void on_buttonName_clicked();`

## 2. Source File (.cpp)
- Find the function definition: `void MyClass::on_buttonName_clicked() { ... }`
- Remove the entire function block

## 3. UI File (.ui) - XML
- Search for the widget that emits the signal
- Look for: `<widget class="QPushButton" name="buttonName">`
- The signal name follows Qt convention: `on_<widgetName>_<signal>`

## 4. MOC File (auto-generated)
- **DO NOT EDIT** - regenerated on build
- If function missing here = missing from header

## 5. Build Directory
- Run clean build: `make clean && qmake && make`

## QUICK REMOVAL COMMANDS
```bash
# Find all references
grep -r "functionName" src/

# Remove from header (example)
sed -i '/void on_functionName_clicked();/d' mainwindow.h

# Remove from source (example)
sed -i '/void MyClass::on_functionName_clicked()/,/^}/d' mainwindow.cpp

# Rebuild
cd build && make clean && cd .. && qmake && cd build && make -j4
```

## NAMING CONVENTION
| UI Widget Name | Signal | Auto-connected Slot |
|----------------|--------|---------------------|
| `btnSave` | `clicked()` | `on_btnSave_clicked()` |
| `actionOpen` | `triggered()` | `on_actionOpen_triggered()` |
| `txtSearch` | `textChanged()` | `on_txtSearch_textChanged()` |

## COMMON ISSUES
- ❌ Function in header but not .cpp → Linker error
- ❌ Function in .cpp but not header → Compiler error  
- ❌ Function in both but no matching UI widget → Runtime warning
- ✅ Function in header, .cpp, AND matching UI widget → Works