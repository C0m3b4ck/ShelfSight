ClassyTk

Object system, widget set and GUI builder for Tcl
by Peter De Rijk (Universiteit Antwerpen)

What is ClassyTk
-----------------

ClassyTk is a widget set and gui builder based on the ClassyTcl object system.
It also requires the Extral extension.

Gui Builder

The ClassyTk Builder can be used to graphically create interfaces. It is
invoked via the cbuild command in the bin directory.

Widget Set

ClassyTcl adds a lot of improvements to Tk, ranging from drag and drop
support (between Tk apps) and a configuration system to a large set of new
widgets and commands, written using the object system. (see further)
While the object system itself only requires Tcl (>8.0), the widgets that
come with it require Tk (of course), and another freely available extension
called ExtraL. ExtraL also does not require compiled code, but can be
speeded up by having it available. Documentation for the widgets is often
somewhat limited, but besides the documentation, you can learn a lot from
sources, the tests and the demos.

Sample applications

The ClassyTcl distribution contains some example applications:

   * cedit: This editor is actually very useable: I use it for all my
     developement
   * ccalc: calculator; demo for the builder
   * cdraw: vector drawing program
   * ctester: app to test widgets
   * cfiles: unfinished: very early stage file manager
   * ccenter: unfinished: very early stage program manager

more information on ClassyTk can be found in
https://derijkp.github.io/ClassyTk/ClassyTk.html

Installation
------------
You should be able to obtain the latest version of ClassyTcl, ClassyTk and ExtraL 
via www on url https://github.com/derijkp/ClassyTk

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

Use
---

To use the widgets that come with the distribution, use the code:
tk appname name
package require ClassyTk
The application name given by the "tk appname" will be used for managing
defaults and configuration options.

To write a new application, you can try out the builder by starting the
program cbuild in the bin directory.

ClassyTcl widgets and commands
------------------------------

Charts

   * BarChart : Barchart that can be drawn on a canvas
   * BarChartDialog : Dialog presenting a barchart and several options for
     its display
   * ChartGrid : grid that can be displayed on canvas
   * LineChart : linechart class that can be drawn on a canvas
   * LineChartDialog : Dialog with a linechart and some controls to change
     its display

Common tools

   * Balloon : help pops up when staying over a widget
   * CmdWidget : Tcl command line widget
   * Config : class used in the configuration system
   * Default : class (not a widget) used by the default mechanism Default
   * DefaultMenu : button with menu to select from user definable defaults
   * DragDrop : class for handling drag and drop to and from widgets
   * DynaMenu : Class used to easily create menus, that can be easily
     changed, and handle key-shortcuts
   * DynaTool : Toolbar widget: nice little buttons in a row
   * Help : Help widget

Dialogs

   * Dialog : dialog with intelligent placing, easy adding of buttons, ...
   * FileSelect : Motif type File Selector Dialog: used by selectfile
     depending on configuration
   * InputDialog : Dialog with one entry
   * ProgressDialog : show progress of some proces in a dialog
   * SaveDialog : widget used by savefile
   * SelectDialog : make a selection out of a list
   * getcolor : select a color getcolor
   * getfont : returns a font selected by the user
   * savefile : select a file name to save a file to
   * selectfile : select a file to open
   * yorn : select yes or no
   * yornDialog : yes or no dialog: used by the command Classy::yorn

New widgets

   * Browser : generic browser widget
   * Editor : reasonably advanced text editor in a widget
   * Fold : foldable frame
   * HTML : displays HTML
   * MultiFrame : placeholder for several frames
   * NoteBook : several sheets to be selected by clicking on tabs
   * OptionBox : select between different values
   * OptionMenu : select between different values using a menu
   * Paned : control the size of another widget
   * Progress : show progress of some process
   * Table : a table ...
   * Tree : a tree that can be drawn on a canvas
   * TreeWidget : a tree widget

Selectors

   * ColorEntry : entry which shows color
   * ColorHSV : HSV color selection widget
   * ColorRGB : RGB color selection widget
   * ColorSample : Select a color from a number of sample colors
   * ColorSelect : color select widget: choose your method
   * FontSelect : to select a font
   * Selector : select relief, justify, ...

Tk improvements

   * Canvas : Canvas with zoom, undo/redo, rotate,save and load, group
   * Entry : entry with label, constraints, command, defaultmenu
   * FileEntry : Classy::Entry with file browse button
   * ListBox : listbox with auto scroll bars, and other extras
   * Message : slightly improved message widget
   * MultiListbox : listbox with more than one line long entries
   * NumEntry : Classy::Entry limited to numbers, and with up and down
     buttons
   * RepeatButton : holding the button repeatidly executes it command
   * ScrolledFrame : frame with auto scroll bars
   * ScrolledText : ClassyTcl Text with auto scroll bars
   * Text : text widget with undo/redo and linking (~multiple views)
   * Toplevel : toplevel with geometry management and destroy command

Contributions
-------------

If you have fixed bugs, made some nice additions to ClassyTcl widgets, etc.,
you can send them to me, and I will consider incorporating them in new
releases. Thanks to the people that have already contributed:
 - Ged Airey <gla@airey.demon.co.uk>

The icons in the package come from various sources: Some were made by
myself (the ugly ones). Most come from a freeware set of icons in KDE.

How to contact me
-----------------

My mailbox gets overwhelmed quite often, and the development of ClassyTcl is
definately not my only task, so responses might be slower than you would
like. However, I will respond as fast as I can.

Peter De Rijk  
VIB - UAntwerp Center for Molecular Neurology  
University of Antwerp - CDE, Parking P4, Building V, Room V1.15  
Universiteitsplein 1, B-2610 Antwerpen, Belgium

E-mail: Peter.DeRijk@uantwerpen.be

Legalities

ClassyTk is Copyright Peter De Rijk, University of Antwerp (UA), 2000 The
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

