extends Node3D
@onready var rigid_body_3d: RigidBody3D = $RigidBody3D


func push_ladder():
	rigid_body_3d.angular_velocity += Vector3.ONE
