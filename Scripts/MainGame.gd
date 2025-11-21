extends Node

func _ready():
	var snake = $SnakeApple.get_used_cells_by_id(1)
	print(snake)
