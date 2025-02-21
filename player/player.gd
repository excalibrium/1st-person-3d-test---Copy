extends CharacterBody3D
class_name PlayerController
var current_mouse_event
var lock := false
@export var camera : Camera3D
@export var raycast : RayCast3D
@export var reeler : Node3D
@export var speed_multiplier : float = 1.0
var shift_toggle := false
var shift := false
@export var flash : SpotLight3D
@export var footstep_audio : AudioStreamPlayer3D
@export var concrete_audio : AudioStreamPlayer3D
@export var current_held : String
var prev_handheld
var handheld : Node3D
var current_slot : int
var slot1
var slot2
var slot3
var in_menu := false
var in_ingame_menu := false
var pistol_bullets := 9
@onready var roofray: RayCast3D = $roofray
@onready var floorray: RayCast3D = $floorray
@export var grass : Material
@onready var myarea: Area3D = $myarea
var fly := false
@onready var item_nodes := {
	"": null,
	"gun": $Camera3D/gun,    # Assign in inspector or _ready()
	"bomb": $bomb
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reeler.global_position = Vector3.ZERO
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	global_rotation.y = camera.global_rotation.y
	camera.global_position = Vector3(global_position.x, global_position.y +1.5, global_position.z)
	if shift == true:
		speed_multiplier = 2.5
	else:
		speed_multiplier = 1.0
	if raycast.get_collider():
		$Camera3D/RayCast3D/MeshInstance3D.global_position = lerp($Camera3D/RayCast3D/MeshInstance3D.global_position,raycast.get_collision_point(), 0.75)
	else:
		$Camera3D/RayCast3D/MeshInstance3D.global_position = lerp($Camera3D/RayCast3D/MeshInstance3D.global_position, $Camera3D/RayCast3D/Node3D.global_position, 0.1)
	$Camera3D/RayCast3D/MeshInstance3D.scale = Vector3.ONE * $Camera3D/RayCast3D/MeshInstance3D.global_position.distance_to($Camera3D.global_position) / 5
	if floorray.get_collider():
		if floorray.get_collider().has_method("get_mesh"):
			if floorray.get_collider().get_mesh() == grass:
				
				if velocity.length() >= 0.2:
				# if the footstep audio isn't playing, play the audio
					if !footstep_audio.playing:
						footstep_audio.pitch_scale = 1.0
						var pitch = speed_multiplier * randf_range(0.8, 1.2)
						footstep_audio.pitch_scale = pitch
						footstep_audio.play()
		else:
			if velocity.length() >= 0.2:
				# if the footstep audio isn't playing, play the audio
				if !concrete_audio.playing:
					concrete_audio.pitch_scale = 1.0
					var pitch = speed_multiplier * randf_range(0.8, 1.2)
					concrete_audio.pitch_scale = pitch
					concrete_audio.play()
func _physics_process(delta: float) -> void:
	if fly == true:
		lock = true
	elif fly == false:
		lock = false
	if roofray.get_collider() and global_position.distance_to(roofray.get_collision_point()) < 10.0:
		$AudioStreamPlayer3D2.volume_db = lerp($AudioStreamPlayer3D2.volume_db, -50.0, 0.1)
	else:
		$AudioStreamPlayer3D2.volume_db = lerp($AudioStreamPlayer3D2.volume_db, -12.0, 0.1)
	flash.look_at($Camera3D/RayCast3D/MeshInstance3D.global_position)
	if is_on_floor() == false and fly == false:
		velocity.y += get_gravity().y * delta
	var input_dir = Input.get_vector("a","d","w","s")
	if fly == false:
		reeler.global_position = Vector3.ZERO
		reeler.position = (reeler.transform.basis * Vector3(input_dir.x,0.0,input_dir.y)).normalized()
	elif fly == true:
		reeler.global_position = $Camera3D/RayCast3D/MeshInstance3D.global_position 
	if lock == false:
		velocity.x = lerp(velocity.x, (reeler.global_position.x - global_position.x) * 2.0* speed_multiplier, 0.1)
		velocity.z = lerp(velocity.z, (reeler.global_position.z - global_position.z) * 2.0*speed_multiplier, 0.1)
	elif fly == true:
		velocity = lerp(velocity, (reeler.global_position - global_position) * 2.0*speed_multiplier * -input_dir.y, 0.5)
		var camerax = camera.transform.basis.x
		camerax.y = 0
		camerax = camerax.normalized()
		velocity.x = lerp(velocity.x, camerax.x * input_dir.x * 20.0* speed_multiplier, 0.1)
		velocity.z = lerp(velocity.z, camerax.z * input_dir.x * 20.0*speed_multiplier, 0.1)

	print(input_dir.x)
	if prev_handheld and prev_handheld != handheld:
		if prev_handheld.has_method("unequip"):
			prev_handheld.unequip()
			prev_handheld = null
	if handheld and handheld.visible == false:
		if handheld.has_method("equip"):
			handheld.equip()
		handheld.visible = true
	move_and_slide()
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("1"):
		if handheld and handheld.lock == false:
			update_hand(0)
		elif handheld == null:
			update_hand(0)
	if event.is_action_pressed("2"):
		if handheld and handheld.lock == false:
			update_hand(1)
		elif handheld == null:
			update_hand(1)

	if event.is_action_pressed("3"):
		if handheld and handheld.lock == false:
			update_hand(2)
		elif handheld == null:
			update_hand(2)
	if event.is_action_pressed("r") and camera.in_ingame_menu == false and in_menu == false:
		if handheld:
			handheld.reload()
	if event.is_action_pressed("shoot") and camera.in_ingame_menu == false and in_menu == false:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if handheld:
			handheld.used()
	if event.is_action_pressed("f") and camera.in_ingame_menu == false and in_menu == false:
		$flash.pitch_scale = randf_range(.8, 1.2)
		$flash.play()
		if flash.spot_range == 15:
			flash.spot_range = 0.1
		else:
			flash.spot_range = 15.0
	if event.is_action_pressed("e") and camera.in_ingame_menu == false and in_menu == false:
		#shift_toggle = !shift_toggle
		interact()
	if event.is_action_pressed("shift"):
		if shift_toggle == true:
			shift = !shift
		else: 
			shift = true
	if event.is_action_released("shift"):
		if shift_toggle == false:
			shift = false
	if event is InputEventMouseMotion and camera.in_ingame_menu == false and in_menu == false:
		current_mouse_event = event
		camera.rotate_y(deg_to_rad(-event.relative.x / 8))
		var new_rotation = camera.rotation.x - deg_to_rad(event.relative.y / 8)
		camera.rotation.x = clamp(new_rotation, deg_to_rad(-89), deg_to_rad(89))
	#if event.is_action_pressed("ui_cancel"):a
		#get_tree().quit()
func update_hand(pressed : int = -1):
	var current
	if pressed >= 0:
		current = camera.ingame_menu.slots[pressed].get_ability()
	else:
		current = pressed
	if current in item_nodes:
		prev_handheld = handheld
		handheld = item_nodes[current]
	else:
		prev_handheld = handheld
		handheld = null
	current_slot = pressed
	print(current_slot)
	print(current)
	print(handheld)
	print(prev_handheld)
func update_item():
	slot1 = camera.ingame_menu.slots[0].get_ability()
	slot2 = camera.ingame_menu.slots[1].get_ability()
	slot3 = camera.ingame_menu.slots[2].get_ability()

	#ability_3 = cam.ingame_menu.slots[2].get_ability()
	#ult = cam.ingame_menu.slots[3].get_ability()
func interact():
	return "interact"

func _on_myarea_area_entered(area: Area3D) -> void:
	if area.is_in_group("Ladder"):
		fly = true


func _on_myarea_area_exited(area: Area3D) -> void:
	if area.is_in_group("Ladder"):
		print("wow")
		fly = false
