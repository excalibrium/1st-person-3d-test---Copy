extends Node3D

@export var player : PlayerController
var seed
var timer := 0.0
@onready var guntext: Sprite3D = $Body/Sprite3D
var gun_picked := false
var deaths := 0

func  _ready() -> void:
	seed = randf()
	deaths = Global.deaths
func _process(delta: float) -> void:
	timer += delta
	
func _physics_process(delta: float) -> void:
	gun_picked = player.camera.ingame_menu.items[0].found
	timer += delta
	if timer >= 8.0 and timer <= 9.0 and gun_picked == false:
		$Body/gunplayer.play("guntext appear")
	if gun_picked == true:
		$Body/Sprite3D.visible = false
		#guntext.modulate = lerp(guntext.modulate, Color(1,1,1,1), 0.1)
