extends CharacterBody3D

@export var player : PlayerController
@export var ray_cast : RayCast3D
@onready var animation_tree: AnimationTree = $AnimationTree
var state_machine
func _ready() -> void:
	state_machine = animation_tree["parameters/playback"]

func kill_player():
	player.death()

func _physics_process(delta: float) -> void:
	ray_cast.look_at(player.global_position)
	ray_cast.rotation.x = 0.0
	if ray_cast.get_collider():
		if ray_cast.get_collider() is PlayerController:
			look_at(player.global_position)
			state_machine.travel("shoot")


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		queue_free()

func shot(by):
	state_machine.travel("death")
