proc select_init {} {
	bind Select <<MExecute>> {select_exec %W %x %y}
	bind Select <<Action-ButtonPress>> {select_action %W %x %y}
	bind Select <<Action-ButtonRelease>> {select_release %W %x %y}
	bind Select <<Action-Motion>> {select_drag %W %x %y}
	bind Select <<MAdd>> {select_action %W %x %y add}
	bind Select <<MAdd-ButtonRelease>> {select_release %W %x %y add}
	bind Select <<MAdd-Motion>> {select_drag %W %x %y}
	bind Select <<Escape>> {select_abort %W %x %y}
}

proc line_init {} {
	bind Line <<Action-ButtonPress>> {line_action %W %x %y;break}
	bind Line <<Action-Motion>> {line_motion %W %x %y;break}
	bind Line <<Escape>> {line_abort %W %x %y;break}
	bind Line <<Adjust>> {line_abort %W %x %y;break}
	bind Line <<MExecute>> {line_abort %W %x %y;break}
}

proc polygon_init {} {
bind Polygon <<Action-ButtonPress>> {polygon_action %W %x %y;break}
bind Polygon <<Action-Motion>> {polygon_motion %W %x %y;break}
bind Polygon <<Escape>> {polygon_abort %W %x %y;break}
bind Polygon <<Adjust>> {polygon_abort %W %x %y;break}
bind Polygon <<MExecute>> {polygon_abort %W %x %y;break}
}

proc oval_init {} {
bind Oval <<Action-ButtonPress>> {oval_action %W %x %y;break}
bind Oval <<Action-Motion>> {oval_motion %W %x %y;break}
bind Oval <<Action-ButtonRelease>> {oval_release %W %x %y;break}
bind Oval <<Escape>> {oval_abort %W %x %y;break}
bind Oval <<Adjust>> {oval_abort %W %x %y;break}
}

proc arc_init {} {
bind Arc <<Action-ButtonPress>> {arc_action %W %x %y;break}
bind Arc <<Action-Motion>> {arc_motion %W %x %y;break}
bind Arc <<Action-ButtonRelease>> {arc_release %W %x %y;break}
bind Arc <<Escape>> {arc_abort %W %x %y;break}
bind Arc <<Adjust>> {arc_abort %W %x %y;break}
}

proc rectangle_init {} {
bind Rectangle <<Action-ButtonPress>> {rectangle_action %W %x %y;break}
bind Rectangle <<Action-Motion>> {rectangle_motion %W %x %y;break}
bind Rectangle <<Action-ButtonRelease>> {rectangle_release %W %x %y;break}
bind Rectangle <<Escape>> {rectangle_abort %W %x %y;break}
bind Rectangle <<Adjust>> {rectangle_abort %W %x %y;break}
}

proc text_init {} {
bind DrawText <<Action>> {text_action %W %x %y; break}
bind DrawText <KeyPress> {text_key %W %A; break}
bind DrawText <BackSpace> {text_key %W backspace; break}
bind DrawText <<Left>> {text_key %W left; break}
bind DrawText <<Right>> {text_key %W right; break}
bind DrawText <<Up>> {text_key %W up; break}
bind DrawText <<Down>> {text_key %W down; break}
bind DrawText <<Action-Motion>> {
	text_select %W drag %x %y
	break
}
bind DrawText <<MXPaste>> {
	%W insert [getprivate %W current(item)] insert [selection get -displayof %W]
	%W selection redraw
	break
}
bind DrawText <<SelectLeft>> {
	text_select %W left
	break
}
bind DrawText <<SelectRight>> {
	text_select %W right
	break
}
bind DrawText <<SelectUp>> {
	text_select %W up
	break
}
bind DrawText <<SelectDown>> {
	text_select %W down
	break
}
bind DrawText <<Home>> {
	text_key %W linestart
	break
}
bind DrawText <<SelectHome>> {
	text_select %W linestart
	break
}
bind DrawText <<End>> {
	text_key %W lineend
	break
}
bind DrawText <<SelectEnd>> {
	text_select %W lineend
	break
}
bind DrawText <<Top>> {
	text_key %W textstart
	break
}
bind DrawText <<SelectTop>> {
	text_select %W textstart
	break
}
bind DrawText <<Bottom>> {
	text_key %W textend
	break
}
bind DrawText <<SelectBottom>> {
	text_select %W textend
	break
}
bind DrawText <Tab> {
	text_key %W \t
	break
}
bind DrawText <Control-i> {
	text_key %W \t
	break
}
bind DrawText <Return> {
	text_key %W \n
	break
}
bind DrawText <<Delete>> {
	text_key %W delete
	break
}
bind DrawText <<BackSpace>> {
	text_key %W backspace
	break
}
bind DrawText <<SelectAll>> {
	text_select %W all
	break
}
bind DrawText <<SelectNone>> {
	text_select %W none
	break
}
bind DrawText <Insert> {
	catch {%W textinsert [selection get -displayof %W]}
	break
}
# The new bindings
bind DrawText <<Copy>> {
	text_key %W copy
	break
}												  
bind DrawText <<Cut>> {
	text_key %W cut
	break
}
bind DrawText <<Paste>> {
	text_key %W paste
	break
}
bind DrawText <<Undo>> {
	undo %W
	break
}
bind DrawText <<Redo>> {
	redo %W
	break
}
# Ignore all Alt, Meta, and Control keypresses unless explicitly bound.
# Otherwise, if a widget binding for one of these is defined, the
# <KeyPress> class binding will also fire and insert the character,
# which is wrong.  Ditto for <Escape>.
bind DrawText <Alt-KeyPress> {# nothing }
bind DrawText <Meta-KeyPress> {# nothing}
bind DrawText <Control-KeyPress> {# nothing}
bind DrawText <Escape> {# nothing}
bind DrawText <KP_Enter> {# nothing}
}

proc zoom_init {} {
bind Zoom <<Action-ButtonPress>> {zoom_action %W %x %y;break}
bind Zoom <<Action-ButtonRelease>> {zoom_release %W %x %y;break}
bind Zoom <<Action-Motion>> {zoom_drag %W %x %y;break}
bind Zoom <<MAdd-ButtonPress>> {zoom_action %W %x %y add;break}
bind Zoom <<MAdd-ButtonRelease>> {zoom_release %W %x %y add;break}
bind Zoom <<MAdd-Motion>> {zoom_drag %W %x %y;break}
bind Zoom <<Escape>> {zoom_abort %W %x %y;break}
}

