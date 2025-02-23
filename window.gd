extends CSGCombiner3D
@onready var glass = $glass
func shot(by):
	if glass:
		glass.queue_free()
		$AudioStreamPlayer3D.play()
		by.heard_reset()
