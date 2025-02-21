extends Camera3D

@export var Mlooker : Node3D
@export var Mray : Node3D
var in_menu := false
var in_ingame_menu := false
@export var ingame_menu : Node3D

@export var Mcursor : Node3D
var pressed_rot
@export var player: PlayerController
@export var rotater: Node3D
var strength := 10.0
var cameramode = 1
var SEXES := 0.0
var SENSITIVITY = 1000
var lockOn = false
var target_change := false
var value
var testvar
var mouse_time := 0.0
var mouse_cd := 0.1
var target_change_cd := 0.05
var target_change_time := 0.0
var next
var current_one
var affirmed_target
const JOY_DEADZONE : float = 0.15
const JOY_V_SENS : float = 0.5
const JOY_H_SENS : float = 0.5
var camera_velocity := Vector3.ZERO
@export var animation_player : AnimationPlayer
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	Mcursor.global_position = $MenuCursorSlot.global_position
	animation_player.play("initing")
func initialize():
	in_menu = true
	Mcursor.set_main_type("pause")

func _input(event: InputEvent) -> void:
	if event is not InputEventMouse and animation_player.current_animation == "initing":
		animation_player.advance(animation_player.current_animation_length - animation_player.current_animation_position - 0.1)
		initialize()
func _process(delta: float) -> void:
	Mcursor.look_at(global_position)
	Mray.look_at(Mcursor.global_position)

func start():
	get_tree().change_scene_to_file("res://test.tscn")
