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
func _ready():
	player = get_tree().get_nodes_in_group("Player")[0]
	if animation_player:
		animation_player.play("started")
func _process(delta: float) -> void:
	Mcursor.look_at(global_position)
	Mray.look_at(Mcursor.global_position)
	
	if in_menu == false and in_ingame_menu == false:
		Mcursor.global_position = $MenuCursorSlot.global_position
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel") and get_parent().menu_lock == false:
			menu_pressed()
	if in_menu == false:
		if Input.is_action_just_pressed("tab") and get_parent().menu_lock == false:
			in_game_menu_pressed("Skills")
	if event is InputEventMouseMotion:
		mouse_time = 0
		testvar = abs(event.relative.x + event.relative.y)
	else:
		testvar = 1

func menu_pressed():
	if in_menu == false:
		Mcursor.set_main_type("pause")
		player.set_physics_process(false)
		Engine.time_scale = 0.01
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	else:
		for i in range(Mcursor.type_history.size() - 1,-1,-1):
			if Mcursor.type_history[i] == Mcursor.main_type:
				Mcursor.type_history.erase(Mcursor.type_history.back())
		Mcursor.main_type = str(Mcursor.type_history.pop_back())
	if Mcursor.main_type == "null":
		player.set_physics_process(true)
		Engine.time_scale = 1.0
		if in_ingame_menu == false:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Mcursor.main_type == "null":
		player.in_menu = false
		in_menu = false
	else:
		player.in_menu = true
		in_menu = true

func in_game_menu_pressed(type: String):
	if ingame_menu.menu_type == type or in_ingame_menu == false:
		in_ingame_menu = !in_ingame_menu
		ingame_menu.open = !ingame_menu.open
		if in_ingame_menu == true:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		elif in_menu == false:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	match type:
		"Skills":
			ingame_menu.change_type(type, null)

func start():
	get_tree().change_scene_to_file("res://world.tscn")

func full_reset():
	Global.deaths = 0
	get_tree().change_scene_to_file("res://title_screen.tscn")
