# *************************************************
#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Tree
# Some code contributed by Ged Airey <gla@airey.demon.co.uk>
# ----------------------------------------------------------------------
#doc Tree title {
#Tree
#} index {
# New widgets
#} shortdescr {
# a tree that can be drawn on a canvas
#} descr {
# subclass of <a href="Class.html">Class</a><br>
# <b>Tree is not a widget type</b>. It is a class whose objects can 
# be associated with a canvas widget. When a Tree instance is 
# associated with a canvas, it will draw a tree on this canvas. 
#}
#doc {Tree options} h2 {
#	Tree options
#} descr {
# A tree object supports the following options in its configure method
#<dl>
#<dt>-canvas<dd>name of canvas to draw the chart
#<dt>-tag<dd>unique tag for all canvas items of the chart
#<dt>-padx<dd>size of indentation
#<dt>-pady<dd>size left open between different lines
#<dt>-font<dd>default font for the text lines
#<dt>-padtext<dd>size between text parts
#<dt>-startx<dd>x location of root
#<dt>-starty<dd>y location of root
#<dt>-rootimage<dd>optional image displayed on root
#<dt>-roottext<dd>optional text displayed on root
#</dl>
#}
#doc {Tree command} h2 {
#	Tree specific methods
#} descr {
#}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Class subclass Classy::Tree

Classy::Tree method init {args} {
	super init
	private $object options data
	array set options {
		-canvas {}
		-padx 10
		-pady 2
		-padtext 4
		-font {}
		-startx 10
		-starty 10
		-rootimage {}
		-roottext {}
		-foreground black
	}
	setprivate $object order ""
	setprivate $object selection ""
	set options(-tag) "Tree:$object"
	eval $object configure $args
	set data() {t c}
	return $object
}


#doc {Tree command destroy} cmd {
#pathname destroy 
#} descr {
#}
Classy::Tree method destroy {} {
	private $object options
	$options(-canvas) delete $options(-tag)
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------


#doc {Tree command configure} cmd {
#pathname configure ?option? ?value? ?option value ...?
#} descr {
# changes the way the tree is displayed. Supported options are given above.
#}
Classy::Tree method configure {args} {
	private $object options
	set len [llength $args]
	if {$len == 0} {
		return [array get options]
	} elseif {$len == 1} {
		return $options([lindex $args 0])
	} else {
		foreach {option value} $args {
			if ![info exists options($option)] {
				error "unknown option \"$option\""
			}
			set previous $options($option)
			set options($option) $value
			switch -- $option {
				-canvas {
					private $object options
					if {"$options(-tag)" == ""} {
						set options(-tag) Tree::$object
					}
					::Classy::todo $object _redraw
				}
				-padx {
					::Classy::todo $object _redraw
				}
				-pady {
					::Classy::todo $object _redraw
				}
				-padtext {
					::Classy::todo $object _redraw
				}
				-font {
					::Classy::todo $object _redraw
				}
				-tag {
					::Classy::todo $object _redraw
				}
				-startx {
					::Classy::todo $object _redraw
				}
				-starty {
					::Classy::todo $object _redraw
				}
				-rootimage {
					::Classy::todo $object _redraw
				}
				-roottext {
					::Classy::todo $object _redraw
				}
				-foreground {
					::Classy::todo $object _redraw
				}
				-selectforeground {
					::Classy::todo $object _redraw
				}
				-selectbackground {
					::Classy::todo $object _redraw
				}
			}
		}
	}
}

Classy::Tree method _drawnode {node} {
	private $object data options
	set canvas $options(-canvas)
	if {"$canvas" == ""} return
	array set drawinfo $data($node)
	set tag $options(-tag)
	set x [$canvas coords $drawinfo(i)]
	set y [list_pop x]
	set sy $y
	set bbox [$canvas bbox $drawinfo(i)]
	set height [expr {[lindex $bbox 3]-[lindex $bbox 1]}]
	set width [expr {[lindex $bbox 2]-[lindex $bbox 0]}]
	set y [expr {$y + $height/2}]
	set plusicon [Classy::geticon plus]
	set minusicon [Classy::geticon minus]
	set padx $options(-padx)
	set pady $options(-pady)
	set padtext $options(-padtext)
	if {"$options(-font)" == ""} {
		set font [option get . treeFont Font]
	} else {
		set font $options(-font)
	}
	if ![info exists drawinfo(l)] {return $y}
	foreach name $drawinfo(l) {
		unset -nocomplain ca
		array set ca $data($name)
		if {![info exists ca(w)]} {
			set ca(i) [$canvas create image $x $y -image $ca(im) \
				-tags [list $tag classy::Tree $name item]]
		} else {
			set ca(i) [$canvas create window $x $y -window $ca(w)\
				-tags [list $tag classy::Tree $name item]]
		}
		set bbox [$canvas bbox $ca(i)]
		set height [expr {[lindex $bbox 3]-[lindex $bbox 1]}]
		set width [expr {[lindex $bbox 2]-[lindex $bbox 0]}]
		set ypos [expr {$y + $height/2.0}]
		set xpos [expr {$x + $width/2.0 + $padx + $ca(len)}]
		$canvas coords $ca(i) $xpos $ypos
		set ca(x) [$canvas create line $x $ypos $xpos $ypos \
			-tags [list $tag classy::Tree $name line] -fill $options(-foreground)]
		$canvas lower $ca(x)
		set ca(ti) [$canvas create text [expr {$x + $padx + $ca(len) + $width + $padtext}] $ypos -text $ca(txt) -anchor w \
			-tags [list $tag classy::Tree $name text] -fill $options(-foreground)]
		if {"$font" != ""} {
			$canvas itemconfigure $ca(ti) -font $font
		}
		set y [expr {$y + $height + $pady}]
		switch $ca(t) {
			f {
				set ca(s) [$canvas create image $x $ypos -image $minusicon \
					-tags [list $tag classy::Tree $name symbol]]
			}
			c {
				set ca(s) [$canvas create image $x $ypos -image $plusicon \
					-tags [list $tag classy::Tree $name symbol]]
			}
		}
		set data($name) [array get ca]
		if {"$ca(t)" == "f"} {
			set y [$object _drawnode $name]
		}
	}
	set drawinfo(y) [$canvas create line $x $sy $x $ypos \
		-tags [list $tag classy::Tree $node yline] -fill $options(-foreground)]
	$canvas lower $drawinfo(y)
	set data($node) [array get drawinfo]
	return $y
}

Classy::Tree method _redraw {} {
	private $object options data selection
	::Classy::canceltodo $object _redraw
	set canvas $options(-canvas)
	if {"$canvas" == ""} return
	$canvas delete $options(-tag)
	if {("$options(-rootimage)" == "")&&("$options(-roottext)" == "")} {
		set i [$canvas create text $options(-startx) $options(-starty) -text "" \
			-tags [list $options(-tag) classy::Tree {}] -fill $options(-foreground)]
		set data() [map_set $data() i $i]
	} else {
		if {"$options(-font)" == ""} {
			set font [option get . treeFont Font]
		} else {
			set font $options(-font)
		}
		if {"$options(-rootimage)" == ""} {
			set im [Classy::geticon sm_folder]
		} else {
			set im $options(-rootimage)
		}
		set i [$canvas create image $options(-startx) $options(-starty) -image $im \
			-tags [list $options(-tag) classy::Tree {}]]
		set bbox [$canvas bbox $i]
		set width [expr {[lindex $bbox 2]-[lindex $bbox 0]}]
		set ti [$canvas create text \
				[expr {$options(-startx) + $width/2 + $options(-padtext)}] $options(-starty) \
				-text $options(-roottext) -anchor w \
				-fill $options(-foreground) \
				-tags [list $options(-tag) classy::Tree {}]]
 		if {"$font" != ""} {$canvas itemconfigure $ti -font $font}
		set data() [map_set $data() i $i ti $ti]
	}
	$object _drawnode {}
	$canvas delete $options(-tag)_selection
#	set bg [Classy::optionget $canvas selectBackground SelectBackground selectBackground]
#	set fg [Classy::optionget $canvas selectForeground SelectForeground selectForeground]
	set bg [$canvas cget -selectbackground]
	set fg [$canvas cget -selectforeground]
	foreach node $selection {
		if ![info exists data($node)] continue
		if [catch {
			set bbox [$canvas bbox [map_get $data($node) i]]
			set x1 [lindex $bbox 0]
			set y1 [lindex $bbox 1]
			set item [map_get $data($node) ti]
			set bbox [$canvas bbox $item]
			$canvas itemconfigure $item -fill $fg
			set x2 [lindex $bbox 2]
			set y2 [lindex $bbox 3]
			if {"$bbox" != ""} {
				$canvas create rectangle $x1 $y1 $x2 $y2 \
					-tags [list $options(-tag) $options(-tag)_selection] \
					-fill $bg -outline $bg
			}
		}] {
			set selection [list_remove $selection $node]
		}
	}
	$canvas lower $options(-tag)_selection
}

#doc {Tree command addnode} cmd {
# pathname addnode parent node args
#} descr {
# add a node to node $parent. The following arguments can be given:
# <ul>
# <li>-text
# <li>-image
# <li>-window
# <li>-length
# <li>-type
# <li>-pos
# </ul>
#}
Classy::Tree method addnode {parent node args} {
	private $object data options
	if {[info exists data($node)]} {
		error "node \"$node\" exists"
	}
	if {![info exists data($parent)]} {
		error "parent node \"$parent\" doesn't exist"
	}
	unset -nocomplain pa
	array set pa $data($parent)
	if {("$pa(t)" != "f")&&("$pa(t)" != "c")} {
		error "parent node \"$parent\" is an endnode"
	}
	array set opt {-text {} -image {} -window {} -length 0 -type folder -pos {}}
	cmd_args "$object addnode parent node" {
		-text {any "text displayed on node"}
		-image {any "image displayed on node"}
		-window {any "window displayed on node"}
		-length {double "length of line leading to node"}
		-type {{oneof folder end} "folder or end"}
		-pos {int "position in list to insert new node"}
	} {} $args
	if {"$opt(-type)" == "folder"} {
		set im [Classy::geticon sm_folder]
		set type c
	} else {
		set im [Classy::geticon sm_file]
		set type e
	}
	if {"$opt(-image)" != ""} {
		set im $opt(-image)
	}
	set pa(t) f
	if ![llength $opt(-pos)] {
		lappend pa(l) $node
	} else {
		set pa(l) [lreplace $pa(l) $opt(-pos) -1 $node]
	}
	set data($parent) [array get pa]
	set data($node) [list t $type p $parent txt $opt(-text) im $im len $opt(-length)]
	if {"$opt(-window)" != ""} {
		lappend data($node) w $opt(-window)
	}
	Classy::todo $object _redraw
}

#doc {Tree command confignode} cmd {
# pathname confignode node args
#} descr {
# configure a node. The following arguments can be given:
# <ul>
# <li>-text
# <li>-image
# </ul>
#}
Classy::Tree method confignode {node args} {
	private $object data options
	if {![info exists data($node)]} {
		error "node \"$node\" does not exists"
	}
	set canvas $options(-canvas)
	array set drawinfo $data($node)
	cmd_args "$object confignode parent node" {
		-text {any "text displayed on node"}
		-image {any "image displayed on node"}
		-window {any "window displayed on node"}
		-length {double "length of line leading to node"}
	} {} $args
	if {[info exists opt(-image)]} {
		set drawinfo(im) $opt(-image)
		$canvas itemconfigure $drawinfo(i) -image $opt(-image)
	}
	if {[info exists opt(-text)]} {
		set drawinfo(txt) $opt(-text)
		$canvas itemconfigure $drawinfo(ti) -text $opt(-text)
	}
	set data($node) [array get drawinfo]
}

#doc {Tree command closenode} cmd {
# pathname closenode node
#} descr {
#}
Classy::Tree method closenode {node} {
	private $object data options
	set data($node) [map_set $data($node) t c]
	Classy::todo $object _redraw
}

#doc {Tree command opennode} cmd {
# pathname opennode node
#} descr {
#}
Classy::Tree method opennode {node} {
	private $object data options
	set data($node) [map_set $data($node) t f]
	Classy::todo $object _redraw
}

#doc {Tree command clearnode} cmd {
# pathname clearnode node
#} descr {
#}
Classy::Tree method clearnode {node} {
	private $object data options
	array set pa $data($node)
	if {("$pa(t)" != "f")&&("$pa(t)" != "c")} {
		error "parent node \"$node\" is an endnode"
	}
	set canvas $options(-canvas)
	if {"$canvas" == ""} return
	if [info exists pa(l)] {
		foreach name $pa(l) {
			unset -nocomplain ca
			if {[info exists data($name)]} {
				array set ca $data($name)
				switch $ca(t) {
					f -
					c {
						$object clearnode $name
						catch {$canvas delete $ca(s)}
					}
				}
				catch {$canvas delete $ca(i)}
				catch {$canvas delete $ca(ti)}
				catch {$canvas delete $ca(x)}
				unset -nocomplain data($name)
			}
		}
		catch {
			catch {$canvas delete $pa(y)}
			unset -nocomplain pa(y)
		}
		unset -nocomplain pa(l)
	}
	set pa(t) c
	set data($node) [array get pa]
	Classy::todo $object _redraw
}

#doc {Tree command deletenode} cmd {
# pathname deletenode node
#} descr {
#}
Classy::Tree method deletenode {node} {
	private $object data options
	set canvas $options(-canvas)
	if {"$canvas" == ""} return
	array set ca $data($node)
	switch $ca(t) {
		f -
		c {
			$object clearnode $node
			$canvas delete $ca(s)
		}
	}
	$canvas delete $ca(i)
	$canvas delete $ca(ti)
	$canvas delete $ca(x)
	set parent $ca(p)
	array set pa $data($parent)
	set pa(l) [list_remove $pa(l) $node]
	if {[llength $pa(l)] == 0} {
		$object clearnode $parent
#		$canvas delete $ca(s)
	} else {
		set data($parent) [array get pa]
	}
	unset -nocomplain data($node)
	Classy::todo $object _redraw
}

#doc {Tree command exists} cmd {
# pathname exists node
#} descr {
#}
Classy::Tree method exists {node} {
	private $object data
	return [info exists data($node)]
}

#doc {Tree command type} cmd {
# pathname type node
#} descr {
#}
Classy::Tree method type {node} {
	private $object data
	switch [map_get $data($node) t] {
		c {return closed}
		f {return open}
		e {return end}
	}
}

#doc {Tree command node} cmd {
# pathname node ...
#} descr {
# <ul>
# <li>pathname node index
# <li>pathname node x y
# </ul>
#}
Classy::Tree method node {index {y {}} {typeVar {}}} {
	private $object data options
	if {$typeVar ne ""} {
		upvar $typeVar type
	}
	set canvas $options(-canvas)
	if {"$canvas" == ""} return
	if {"$y" != ""} {
		set index [lindex [$canvas find overlapping [$canvas canvasx $index] [$canvas canvasy $y] [$canvas canvasx $index] [$canvas canvasy $y]] end]
	}
	set tags [$canvas itemcget $index -tags]
	set type [lindex $tags 3]
	return [lindex $tags 2]
}

#doc {Tree command what} cmd {
# pathname what ...
#} descr {
# <ul>
# <li>pathname what index
# <li>pathname what x y
# </ul>
#}
Classy::Tree method what {index {y {}}} {
	private $object data options
	set canvas $options(-canvas)
	if {"$canvas" == ""} return
	if {"$y" != ""} {
		set index [lindex [$canvas find overlapping [$canvas canvasx $index] [$canvas canvasy $y] [$canvas canvasx $index] [$canvas canvasy $y]] end]
	}
	set tags [$canvas itemcget $index -tags]
	return [lindex $tags 3]
}

#doc {Tree command parentnode} cmd {
# pathname parentnode node
#} descr {
#}
Classy::Tree method parentnode {node} {
	private $object data
	return [map_get $data($node) p]
}

#doc {Tree command children} cmd {
# pathname children node
#} descr {
#}
Classy::Tree method children {node} {
	private $object data
	return [map_get $data($node) l]
}

#doc {Tree command selection} cmd {
# pathname selection ?option? ...
#} descr {
# <ul>
# <li>pathname selection
# <li>pathname selection clear
# <li>pathname selection add node ?node ...?
# <li>pathname selection set node ?node ...?
# <li>pathname selection remove node ?node ...?
# </ul>
#}
Classy::Tree method selection {{cmd {}} args} {
	private $object selection data
	switch $cmd {
		"" {
			set list ""
			foreach el $selection {
				if [info exists data($el)] {lappend list $el}
			}
			set selection $list
			return $selection
		}
		add {eval list_addnew selection $args}
		set {set selection $args}
		remove {set selection [list_lremove $selection $args]}
		clear {set selection ""}
		default {return -code error "Unknown option \"$cmd\""}
	}
	Classy::todo $object _redraw
}

#doc {Tree command nodes} cmd {
# pathname nodes parent
#} descr {
# returns the child nodes from $parent
#}
Classy::Tree method nodes {parent} {
	private $object data options
	if ![info exists data($parent)] {
		error "parent node \"$parent\" doesn't exist"
	}
	array set pa $data($parent)
	return [get pa(l)]
}

Classy::Tree method edit {node command} {
	private $object data options
	set canvas $options(-canvas)
	array set d $data($node)
	set bbox [$canvas bbox $d(ti)]
	$canvas delete $options(-tag)_edit
	catch {destroy $canvas.classy_edit}
	entry $canvas.classy_edit
	$canvas create window [expr {[lindex $bbox 0]-1}] [expr {[lindex $bbox 1]-1}] \
		-tags [list $options(-tag) $options(-tag)_edit] \
		-window $canvas.classy_edit \
		-anchor nw -height [expr {[lindex $bbox 3]-[lindex $bbox 1]+2}] \
		-width [expr {[lindex $bbox 2]-[lindex $bbox 0]+2}]
	$canvas.classy_edit insert end [$canvas itemcget $d(ti) -text]
	bind $canvas.classy_edit <<Return>> "$command \[$canvas.classy_edit get\] ; $object stopedit"
}

Classy::Tree method stopedit {} {
	private $object data options
	set canvas $options(-canvas)
	destroy $canvas.classy_edit
	$canvas delete $options(-tag)_edit
}

# Code contributed by Ged Airey <gla@airey.demon.co.uk>
# -----------------------------------------------------

Classy::Tree method settext {theNode theText} {
	private $object data options
	array set d $data($theNode)
	set d(txt) $theText
	set data($theNode) [array get d]
	Classy::todo $object _redraw
}

Classy::Tree method gettext {theNode} {
	private $object data options
	array set d $data($theNode)
	return $d(txt)
}

Classy::Tree method movenode {cmd node} {
	private $object data
	set aParent [$object parentnode $node]
	array set aParentArray $data($aParent)
	set aParentNodeList $aParentArray(l)
	set aNodePos [lsearch -exact $aParentNodeList $node]
	set aLastNodePos [llength $aParentNodeList]
	switch $cmd {
		up {if {$aNodePos == 0} {return -1}; set aNewNodePos [incr aNodePos -1]}
		down {if {$aNodePos == $aLastNodePos} {return -1}; set aNewNodePos [incr aNodePos]}
	}
	set aParentNodeList [lreplace $aParentNodeList $aNodePos $aNodePos]
	set aParentNodeList [linsert $aParentNodeList $aNewNodePos $node]
	set aParentArray(l) $aParentNodeList
	set data($aParent) [array get aParentArray]
	Classy::todo $object _redraw
}

Classy::Tree method see {node} {
	private $object options
	set canvas $options(-canvas)
	foreach {sx1 sy1 sx2 sy2} [$canvas cget -scrollregion] break
	set width [expr {$sx2-$sx1}]
	set height [expr {$sy2-$sy1}]
	foreach {fsx1 fsx2} [$canvas xview] break
	foreach {fsy1 fsy2} [$canvas yview] break
	foreach {x1 y1 x2 y2} [$canvas bbox $node] break
	if {![info exists x1]} {error "node \"$node\" not found"}
	set x1 [expr {double($x1-$sx1)/$width}]
	set x2 [expr {double($x2-$sx1)/$width}]
	set y1 [expr {double($y1-$sy1)/$height}]
	set y2 [expr {double($y2-$sy1)/$height}]
	if {($x1 >= $fsx1) && ($x1 <= $fsx2) && ($y1 >= $fsy1) && ($y1 <= $fsy2)} {
		return
	}
	set x [expr {$x2-[winfo width $canvas]}]
	if {$x > $x1} {set x $x1}
	if {$x < 0} {set x 0}
	$canvas xview moveto $x
	$canvas yview moveto $y1
}
