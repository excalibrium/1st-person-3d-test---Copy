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
var pistol_bullets := 0
@onready var roofray: RayCast3D = $roofray
@onready var floorray: RayCast3D = $floorray
@export var grass : Material
@onready var myarea: Area3D = $myarea
var fly := false
@onready var dialogue_player: AnimationPlayer = $Camera3D/Dialogue/dialoguePlayer
var wasted_dialogues : Array[String]
@onready var mesh: Node3D = $Mesh
@onready var armr: Node3D = $Mesh/Armature/Skeleton3D/arm_R/armr
@onready var m_animation_player: AnimationPlayer = $Mesh/MAnimationPlayer
@onready var m_animation_tree: AnimationTree = $Mesh/MAnimationTree
var state_machine
var previous_velocity_y : float
var menu_lock := false
var deaths := 0
var timer := 0.0
var movement_key_pressed := false
var shift_pressed := false
var tab_pressed := false
var e_pressed := false
var played_a := false
var played_b := false
var played_c := false
var played_d := false

@onready var item_nodes := {
	"": null,
	"gun": $Mesh/Armature/Skeleton3D/Hand_R/gun,    # Assign in inspector or _ready()
	"button": $Mesh/Armature/Skeleton3D/Hand_R/button_model
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	deaths = Global.deaths
	state_machine = m_animation_tree["parameters/playback"]
	reeler.global_position = Vector3.ZERO
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	if lock == false:
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
	move_and_slide()
func _physics_process(delta: float) -> void:
	print(deaths)
	if movement_key_pressed and timer < 5.0:
		played_a = true
	if timer > 5.0 and timer < 6.0 and movement_key_pressed == false:
		$Camera3D/wasdmove/wasdmove.play("show")
	if timer > 6.0 and played_a == false and movement_key_pressed == true:
		$Camera3D/wasdmove/wasdmove.play("hide")
		played_a = true
	if shift_pressed and timer < 10.0:
		played_b = true
	if timer > 10.0 and timer < 11.0 and shift_pressed == false:
		$Camera3D/shifttorun/shiftto.play("show")
	if timer > 11.0 and played_b == false and shift_pressed == true:
		$Camera3D/shifttorun/shiftto.play("hide")
		played_b = true

	#if camera.ingame_menu.items[0].found and e_pressed == true:
		#played_d = true
	if timer > 4.5 and timer < 5.5 and camera.ingame_menu.items[0].found == false and e_pressed == false:
		$Camera3D/etointeract/etoint.play("show")
		played_d = true
	if camera.ingame_menu.items[0].found == true and e_pressed == true and played_d == true:
		$Camera3D/etointeract/etoint.play("hide")
		played_d = false

	#if camera.ingame_menu.items[0].found and tab_pressed == true and timer < 5.0:
		#played_c = true
	if camera.ingame_menu.items[0].found and tab_pressed == false and played_c == false:
		$Camera3D/tabtoinv/tabinv.play("show")
		played_c = true
	if camera.ingame_menu.items[0].found and tab_pressed == true and played_c == true:
		$Camera3D/tabtoinv/tabinv.play("hide")
		played_c = false
	#if timer > 5.0 and timer < 6.0 and movement_key_pressed == false:
		#$wasdmove/wasdmove.play("show")
		#var shown = true
		#if timer > 5.0 and shown == true:
			#$wasdmove/wasdmove.play("hide")
	if velocity.y < 0:
		$air.volume_db = -42.0 / 1 + (-velocity.y * 2.5)
		
	else:
		$air.volume_db = -42.0
	#mesh.global_rotation.y = camera.global_rotation.y

	if roofray.get_collider() and global_position.distance_to(roofray.get_collision_point()) < 10.0:
		$AudioStreamPlayer3D2.volume_db = lerp($AudioStreamPlayer3D2.volume_db, -50.0, 0.1)
	else:
		$AudioStreamPlayer3D2.volume_db = lerp($AudioStreamPlayer3D2.volume_db, -12.0, 0.1)
	flash.look_at($Camera3D/RayCast3D/MeshInstance3D.global_position)

	if not is_on_floor():
		previous_velocity_y = velocity.y
	if is_on_floor() and previous_velocity_y < -10.0:
		death()
		previous_velocity_y = 0.0
	if is_on_floor() == false and fly == false:
		velocity.y += get_gravity().y * delta
	var vel_difference = velocity.y - previous_velocity_y
	#if previous_velocity_y < 0:
		#print(vel_difference, "yay")
		#if vel_difference > 2.0:
			#print("oof")
	var input_dir = Input.get_vector("a","d","w","s")
	if fly == false:
		reeler.global_position = Vector3.ZERO
		reeler.position = (reeler.transform.basis * Vector3(input_dir.x,0.0,input_dir.y)).normalized()
	elif fly == true:
		reeler.global_position = $Camera3D/RayCast3D/MeshInstance3D.global_position 
	if lock == false and fly == false:
		velocity.x = lerp(velocity.x, (reeler.global_position.x - global_position.x) * 1.0* speed_multiplier, 0.1)
		velocity.z = lerp(velocity.z, (reeler.global_position.z - global_position.z) * 1.0*speed_multiplier, 0.1)
	elif fly == true:
		velocity = lerp(velocity, (reeler.global_position - global_position) * 2.0*speed_multiplier * -input_dir.y, 0.5)
		var camerax = camera.transform.basis.x
		camerax.y = 0
		camerax = camerax.normalized()
		velocity.x = lerp(velocity.x, camerax.x * input_dir.x * 20.0* speed_multiplier, 0.1)
		velocity.z = lerp(velocity.z, camerax.z * input_dir.x * 20.0*speed_multiplier, 0.1)

	if prev_handheld and prev_handheld != handheld:
		if prev_handheld.has_method("unequip"):
			prev_handheld.unequip()
			state_machine.travel("Unequip")
			prev_handheld = null
	if handheld and handheld.visible == false:
		if handheld.has_method("equip"):
			handheld.equip()
			state_machine.travel("Equip")
		handheld.visible = true
	move_and_slide()
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("e"):
		e_pressed = true
	if event.is_action_pressed("tab"):
		tab_pressed = true
	if event.is_action_pressed("w"):
		movement_key_pressed = true
	if event.is_action_pressed("a"):
		movement_key_pressed = true
	if event.is_action_pressed("s"):
		movement_key_pressed = true
	if event.is_action_pressed("d"):
		movement_key_pressed = true
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
			state_machine.travel("Reload")
	if event.is_action_pressed("shoot") and camera.in_ingame_menu == false and in_menu == false:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if handheld:
			handheld.used()
			if handheld == item_nodes["gun"]:
				state_machine.travel("Shoot")
			if handheld == item_nodes["button"]:
				camera.animation_player.play("Extermination")
				velocity = Vector3.ZERO
				lock = true
				menu_lock = true
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
		shift_pressed = true
		if shift_toggle == true:
			shift = !shift
		else: 
			shift = true
	if event.is_action_released("shift"):
		if shift_toggle == false:
			shift = false
	if event is InputEventMouseMotion and camera.in_ingame_menu == false and in_menu == false and lock == false:
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
func update_item():
	slot1 = camera.ingame_menu.slots[0].get_ability()
	slot2 = camera.ingame_menu.slots[1].get_ability()
	slot3 = camera.ingame_menu.slots[2].get_ability()

	#ability_3 = cam.ingame_menu.slots[2].get_ability()
	#ult = cam.ingame_menu.slots[3].get_ability()
func interact():
	if raycast.get_collider() and raycast.get_collider().has_method("interacted"):
		raycast.get_collider().interacted(self)
		
func recieve_item(item_code):
	camera.ingame_menu.items[item_code].found = true
	$AudioStreamPlayer3D3.play()
	
func _on_myarea_area_entered(area: Area3D) -> void:
	if area.is_in_group("Ladder"):
		fly = true
	match area.name:
		"nearing_main":
			if deaths != 1 and "approach_1" not in wasted_dialogues:
				dialogue_player.play("approach_1")
				wasted_dialogues.append("approach_1")
			if deaths == 1 and "approach_2" not in wasted_dialogues:
				dialogue_player.play("approach_2")
				wasted_dialogues.append("approach_2")
func _on_myarea_area_exited(area: Area3D) -> void:
	if area.is_in_group("Ladder"):
		fly = false
	match area.name:
		"nearing_main":
			if velocity.y > 2:
				dialogue_player.play("launched_1")
				wasted_dialogues.append("launched_1")

func death():
	$Camera3D/Dialogue/Sprite3D2.visible = false
	lock = true
	velocity = Vector3.ZERO
	camera.animation_player.play("restarting")
	state_machine.travel("Death")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"restarting":
			lock = false
			menu_lock = false
			in_menu = false
			camera.in_menu = false
		"started":
			menu_lock = false
func _on_animation_player_animation_started(anim_name: StringName) -> void:
	match anim_name:
		"restarting":
			menu_lock = true
			lock = true
		"started":
			menu_lock = true

func heard_reset():
	camera.animation_player.play("heard_restarting")
	Global.death()

func _on_m_animation_tree_animation_started(anim_name: StringName) -> void:
	match anim_name:
		"Death":
			Global.death()
			#print("LOOk")
			camera.rotation_degrees.x = -75.0

func last_dialogue():
	dialogue_player.play("approach_3")
