proc Extral::compat {} {
namespace eval ::string {}
namespace eval ::list {}
foreach {old new} {
	literate list_iterate
	lnext list_next
	scantime time_scan
	formattime time_format
} {
	catch {interp alias {} $old {} $new}
}

foreach option {
	regsub find sub cor merge unmerge pop shift load write push unshift
	arrayset common union eor remove lremove addnew
} {
	catch {interp alias {} l$option {} list_$new}
}

foreach option {set get unset fields} {
	catch {interp alias {} structl$option {} map_$option}
}

foreach option {read write} {
	catch {interp alias {} ${option}file {} file_$option}
}

catch {
proc lmath {option args} {
	eval lmath_$option $args
}
}

catch {
proc lmanip {option args} {
	eval list_$option $args
}
}

catch {
proc amanip {option args} {
	eval array_$option $args
}
}

}
# obsolete 
# ffind
