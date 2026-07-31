proc cut {object {tag _sel}} {
	private $object canvas
	set list [list_remdup [list_subindex [$canvas mitemcget $tag -tags] 0]]
	$canvas cut $tag
}

proc copy {object {tag _sel}} {
	private $object canvas
	$canvas copy $tag
}

proc paste {object} {
	private $object canvas
	$canvas paste
}
