extends Node2D

signal operator_changed
var option
var remainder

func update_score(snake_lenght):
	$Background/ScoreText.text = str(snake_lenght)


func update_operation():
	
	randomize()
	$Background/HBoxContainer/Num1.text = "(" + str((randi() % 21) - 10) + ")"
	$Background/HBoxContainer/Num2.text = "(" + str((randi() % 21) - 10) + ")"
	
	while int($Background/HBoxContainer/Num2.text) == 0:
		$Background/HBoxContainer/Num2.text = "(" + str((randi() % 21) - 10) + ")"
	
	remainder = int($Background/HBoxContainer/Num1.text) % int($Background/HBoxContainer/Num2.text)
	


func update_operator():
		
	randomize()
	if remainder == 0:
		option = randi() % 4
	else:
		option = randi() % 3
	match(option):
		0:
			$Background/HBoxContainer/Op.text = "+"
		1:
			$Background/HBoxContainer/Op.text = "-"
		2:
			$Background/HBoxContainer/Op.text = "X"
		3:
			$Background/HBoxContainer/Op.text = "÷"	
	emit_signal("operator_changed",option)
	
	
	return option

func update_best_score(points):
	$Background/BestScoreText.text = str(points)

