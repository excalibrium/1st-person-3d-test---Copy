extends Node3D
class_name weapon
@onready var flash: Node3D = $flash
var lock := false
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var primed := false
@export var ray_cast_3d: RayCast3D
@export var ray_cast_3d2: RayCast3D
@export var ray_cast_3d3: RayCast3D
@export var ray_cast_3d4: RayCast3D
@export var ray_cast_3d5: RayCast3D
var bullets := 0
var target_position: Vector3
@onready var sprite_3d: Sprite3D = $Sprite3D
var sprite_3d_original_position : Vector3
var show_ammo_timer := 0.0
@export var gunray : RayCast3D

func _ready() -> void:
	bullets = Global.deaths
	sprite_3d.position.z -= 0.25
	sprite_3d_original_position = sprite_3d.position
	update_ammo()
	show_ammo()
func _physics_process(delta: float) -> void:
	if show_ammo_timer < 5.0:
		show_ammo_timer += delta
	if show_ammo_timer >= 3.0 and show_ammo_timer < 5.0:
		hide_ammo()
	sprite_3d.look_at(owner.camera.global_position)
	#rotation_degrees.x = lerpf(rotation_degrees.x, 0.0, 10.0 * delta)
	if ray_cast_3d5.get_collider() and ray_cast_3d5.get_collider() is not PlayerController:
		target_position = Vector3(0.45, -0.3, -1.1) + Vector3(0, 0, clamp(2.0 - ray_cast_3d5.get_collision_point().distance_to(self.global_position), 0, 2.0) * 0.8)
	else:
		if ray_cast_3d4.get_collider() and ray_cast_3d4.get_collider() is not PlayerController:
			target_position = Vector3(0.45, -0.3, -1.1) + Vector3(0, 0, clamp(2.0 - ray_cast_3d4.get_collision_point().distance_to(self.global_position), 0, 2.0) * 0.8)
		else:
			if ray_cast_3d3.get_collider() and ray_cast_3d3.get_collider() is not PlayerController:
				target_position = Vector3(0.45, -0.3, -1.1) + Vector3(0, 0, clamp(2.0 - ray_cast_3d3.get_collision_point().distance_to(self.global_position), 0, 2.0) * 0.8)
			else:
				if ray_cast_3d2.get_collider() and ray_cast_3d2.get_collider() is not PlayerController:
					target_position = Vector3(0.45, -0.3, -1.1) + Vector3(0, 0, clamp(2.0 - ray_cast_3d2.get_collision_point().distance_to(self.global_position), 0, 2.0) * 0.8)
				else:
					if ray_cast_3d.get_collider() and ray_cast_3d.get_collider() is not PlayerController:
						target_position = Vector3(0.45, -0.3, -1.1) + Vector3(0, 0, clamp(2.0 - ray_cast_3d.get_collision_point().distance_to(self.global_position), 0, 2.0) * 0.8)
					else:
						target_position = Vector3(0.45, -0.3, -1.1)
	#position = position.lerp(target_position, delta * 20.0)
func used():
	show_ammo()
	if lock == false:
		primed = false
		if bullets > 0:
			animation_player.play("shoot")
			lock = true
		else:
			animation_player.play("no_bullets")
	if animation_player.current_animation_position > 0.095:
		primed = true
func recoil():
	$AudioStreamPlayer3D.pitch_scale = randf_range(1.0,1.2)
	$AudioStreamPlayer3D.play(0.33)
	create_impact_decal(gunray.get_collision_point(), gunray.get_collision_normal(), gunray.get_collider())
	if gunray.get_collider() and gunray.get_collider().has_method("shot"):
		gunray.get_collider().shot(owner)
	flash.rotation_degrees.z = randf_range(-360.0, 360.0)
	flash.visible = true
	$GPUParticles3D.restart()
	$GPUParticles3D.emitting = true
	$GPUParticles3D.restart()
	#rotation_degrees.x -= 15.0
	bullets -= 1
	update_ammo()
func update_ammo():
	$SubViewport/Label.text = str(bullets) + str("/") + str(owner.pistol_bullets) 
func hide_ammo():
	if sprite_3d.visible == true:
		show_ammo_timer = 5.0
		sprite_3d.visible = false
		sprite_3d.position.z += 0.25
func show_ammo():
	show_ammo_timer = 0.0
	if sprite_3d.visible == false:
		sprite_3d.visible = true
		sprite_3d.position.z -= 0.25
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	
	match anim_name:
		"shoot":
			lock = false
			if primed:
				used()
		"equip":
			show_ammo()
			lock = false
			if primed:
				used()
		"unequip":
			lock = false
			visible = false
		"no_bullets":
			primed = false
		"reload":
			show_ammo()
			if lock == true:
				sprite_3d.position.z += 0.25
				lock = false
			if owner.pistol_bullets <= 0:
				return
	# Special case: Chamber holding (+1 capacity)
			if bullets == 7 and owner.pistol_bullets >= 1:
				owner.pistol_bullets -= 1
				bullets += 1
				update_ammo()
				return
	# Normal reload for other cases
			if bullets < 8:
				var bullets_needed = 7 - bullets  # Space left in magazine (7 is base capacity)
				var bullets_to_add = min(bullets_needed, owner.pistol_bullets)
		# Update bullet counts
				bullets += bullets_to_add
				owner.pistol_bullets -= bullets_to_add
		# Play reload sound
				$AudioStreamPlayer3D3.play()
				update_ammo()
func equip():
	if lock == false:
		lock = true
		animation_player.play("equip")
func reload():
	if lock == false:
		$AudioStreamPlayer3D2.play()
		animation_player.play("reload")
		sprite_3d.position.z -= 0.25
	lock = true
func unequip():
	if lock == false:
		lock = true
		animation_player.play("unequip")

func create_impact_decal(hit_position: Vector3, normal: Vector3, who):
	var decal = Decal.new()
	decal.texture_albedo = preload("res://texture/decals/bullethole.png")
	decal.texture_normal = preload("res://texture/decals/bullethole_N.png")
	decal.size = Vector3(0.5, 0.5, 0.5)  # Adjust size as needed
	if who:
		who.add_child(decal)
	decal.global_position = hit_position
	decal.look_at(hit_position + normal)
	decal.rotation_degrees.x -= 90
	decal.cull_mask = decal.cull_mask-2
	# Orient the decal to face the surface
	# You might need to adjust this depending on your decal's orientation
	#decal.look_at(hit_position - normal, Vector3.UP)
