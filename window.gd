extends CSGCombiner3D
@onready var glass = $glass
func shot():
	if glass:
		glass.queue_free()
		$AudioStreamPlayer3D.play()
