extends StaticBody3D
@export var item_code : int

func interacted(player):
	player.recieve_item(item_code)
	queue_free()
