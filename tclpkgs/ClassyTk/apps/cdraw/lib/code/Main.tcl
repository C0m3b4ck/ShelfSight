proc main args {
global numbering
set w [mainw .mainw]
zoom_init
line_init
polygon_init
text_init
rectangle_init
oval_init
arc_init
select_init
set canvas $w.canvas
#focus $w
catch {destroy .logo}
undoon $w 1
if [llength $args] {
	fileload .mainw [lindex $args 0]
}
select_start $w
}
