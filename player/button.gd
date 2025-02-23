extends Node3D
var found := false
var lock := false
func used():
	owner.camera.animation_player.play("Extermination")

func recoil():
	print("recoil")

func equip():
	visible = true

func reload():
	print("reload")
	
func unequip():
	visible = false
