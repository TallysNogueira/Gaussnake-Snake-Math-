extends Node

func _ready():
	var snake = $SnakeApple.get_cell(0,0)
	print(snake)
