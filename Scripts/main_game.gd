extends Node

const SNAKE = 0
var snake_body = [Vector2(4,7),Vector2(3,7),Vector2(2,7)]
var snake_direction = Vector2(1,0)


const APPLE = 0
var apple
var apple_labels = []
var apples = []
var apple_nums = []

var add_apple = false


var correct_label = 0

var move_up = true
var move_down = true

var num1 
var num2 
var remainder

var song_list = [preload("res://Sound/song1.wav"),preload("res://Sound/song2.wav")]
onready var music_player = $Music
var is_mute = false

var current_operator = 0
var best_score = 0
var score = 0


func _ready():
	OS.center_window()
	play_music()
	
	$Score.connect("operator_changed",self,"_on_operator_changed")
	spawn_apples()	


	
func _process(delta):
	check_game_over()	

func _on_operator_changed(op):
	current_operator = op

func setup_result(option,n1,n2):
	var result = 0
	match option:
		0:
			result = n1 + n2
		1:
			result = n1 - n2
		2:
			result = n1 * n2
		3:
			result = n1 / n2
	return result
	
func setup_nums():
	
	randomize()
	
	var num_label
	while true:
		num_label = ((randi() % 21) - 10) + correct_label
		if num_label in apple_nums:
			continue	
		else:
			apple_nums.append(num_label)
			break
	return num_label

func spawn_apples():
	apple_nums.clear()
	get_tree().call_group("score_group","update_operation")
	get_tree().call_group("score_group","update_operator")

	
	yield(get_tree(), "idle_frame")
	num1 = int($Score/Background/HBoxContainer/Num1.text)
	num2 = int($Score/Background/HBoxContainer/Num2.text)

	
	correct_label = setup_result(current_operator,num1,num2)
	apples.clear()
	apple_labels.clear()
	apple_nums.append(correct_label)


	randomize()
	var apple_count = randi() % 3 + 2

	# Spawn maçãs erradas
	for i in range(apple_count):
		var pos = place_apple()
		place_apple_at(pos)
		apples.append(pos)

		var num_label = setup_nums()
		var lbl = Label.new()
		lbl.text = str(num_label)
		add_child(lbl)

		update_apple_label_position(lbl, pos)
		apple_labels.append(lbl)

	# Spawn maçã correta
	var correct_pos = place_apple()
	place_apple_at(correct_pos)
	apples.append(correct_pos)
	

	var correct_lbl = Label.new()
	correct_lbl.text = str(correct_label)
	add_child(correct_lbl)
	update_apple_label_position(correct_lbl, correct_pos)
	apple_labels.append(correct_lbl)

	#print(remainder)

func place_apple_at(pos):
	$AppleMap.set_cell(pos.x, pos.y, APPLE)

func place_apple():
	var pos = Vector2()
	
	randomize()
	while true:
		pos =  Vector2(randi() % 15,1 + randi() % 14)
		if pos in apples:
			continue
		
		if pos in snake_body:
			continue
		
		else:
			break
	return pos
	
func update_apple_label_position(apple_label,apple_pos):
	
	var cell_to_world = $AppleMap.map_to_world(apple_pos)
	if correct_label >= 0 and correct_label <= 9:
		cell_to_world += $AppleMap.cell_size/2.7
	elif correct_label > 9:
		cell_to_world += $AppleMap.cell_size/3.2
	elif correct_label < 0 and correct_label >= -9:
		cell_to_world += $AppleMap.cell_size/2.9
	elif correct_label < - 9:
		cell_to_world += $AppleMap.cell_size/3.1
		
	apple_label.rect_position = cell_to_world

func remove_all_apples():

	for pos in apples:
		$AppleMap.set_cell(pos.x, pos.y, -1)
	apples.clear()


	for lbl in apple_labels:
		lbl.queue_free()
	apple_labels.clear()	
	
func check_apple_eaten():
	
	for i in range(apples.size()):

		if apples[i] == snake_body[0]:
			if int(apple_labels[i].text) == correct_label:
				apple_labels[i].visible = false
				
				$AppleMap.set_cell(apples[i].x, apples[i].y,-1)
				$CrunchFX.play()
				apples.remove(i)
				apple_labels.remove(i)
				apple_nums.clear()
				
				add_apple = true
				get_tree().call_group("score_group","update_score",snake_body.size() - 2)
				score = snake_body.size() - 2
				
				if score > best_score:
					best_score = score
					get_tree().call_group("score_group","update_best_score",best_score)
				
				remove_all_apples()

				remove_all_apples()
				return
			else:
				$DeathFX.play()
				apple_nums.clear()
				reset()
				remove_all_apples()
				spawn_apples()
				return	

func draw_snake():
	for block_index in snake_body.size():
		var block = snake_body[block_index]
		
		if block_index == 0:
			var head_dir = relation2(snake_body[0],snake_body[1])
			if head_dir == 'top':
				$SnakeMap.set_cell(block.x,block.y,SNAKE,false,true,false,Vector2(2,1))
			elif head_dir == 'bottom':
				$SnakeMap.set_cell(block.x,block.y,SNAKE,false,false,false,Vector2(2,1))
			elif head_dir == 'left':
				$SnakeMap.set_cell(block.x,block.y,SNAKE,false,false,false,Vector2(2,0))
			elif head_dir == 'right':
				$SnakeMap.set_cell(block.x,block.y,SNAKE,true,false,false,Vector2(2,0))
		elif block_index == snake_body.size() - 1:
			var tail_dir = relation2(snake_body[-1],snake_body[-2])
			if tail_dir == 'top':
				$SnakeMap.set_cell(block.x,block.y,SNAKE,false,false,false,Vector2(1,1))
			elif tail_dir == 'bottom':
				$SnakeMap.set_cell(block.x,block.y,SNAKE,false,true,false,Vector2(1,1))
			elif tail_dir == 'left':
				$SnakeMap.set_cell(block.x,block.y,SNAKE,true,false,false,Vector2(0,0))
			elif tail_dir == 'right':
				$SnakeMap.set_cell(block.x,block.y,SNAKE,false,false,false,Vector2(0,0))
		else:
			var previous_block = snake_body[block_index + 1] - block
			var next_block = snake_body[block_index - 1] - block

			if previous_block.x == next_block.x:
				$SnakeMap.set_cell(block.x,block.y,SNAKE,false,false,false,Vector2(4,1))
			elif previous_block.y == next_block.y:	
				$SnakeMap.set_cell(block.x,block.y,SNAKE,false,false,false,Vector2(4,0))							
			else:
				if previous_block.x == -1 and next_block.y == -1 or next_block.x == -1 and previous_block.y == -1:
					$SnakeMap.set_cell(block.x,block.y,SNAKE,true,true,false,Vector2(5,0))
				if previous_block.x == -1 and next_block.y == 1 or next_block.x == -1 and previous_block.y == 1:
					$SnakeMap.set_cell(block.x,block.y,SNAKE,true,false,false,Vector2(5,0))	
				if previous_block.x == 1 and next_block.y == -1 or next_block.x == 1 and previous_block.y == -1:
					$SnakeMap.set_cell(block.x,block.y,SNAKE,false,true,false,Vector2(5,0))
				if previous_block.x == 1 and next_block.y == 1 or next_block.x == 1 and previous_block.y == 1:
					$SnakeMap.set_cell(block.x,block.y,SNAKE,false,false,false,Vector2(5,0))															

func move_snake():
	if add_apple:
		delete_tiles(SNAKE)
		var body_copy = snake_body.slice(0, snake_body.size() - 1)
		var new_head = body_copy[0] + snake_direction
		body_copy.insert(0,new_head)
		snake_body = body_copy
		add_apple = false
	else:
		delete_tiles(SNAKE)
		var body_copy = snake_body.slice(0, snake_body.size() - 2)
		var new_head = body_copy[0] + snake_direction
		body_copy.insert(0,new_head)
		snake_body = body_copy

func relation2(first_block:Vector2,second_block:Vector2):
	var block_relation = second_block - first_block
	if block_relation == Vector2(0,-1): return 'top'
	if block_relation == Vector2(0,1): return 'bottom'
	if block_relation == Vector2(-1,0): return 'left'		
	if block_relation == Vector2(1,0): return 'right'

func delete_tiles(id:int):
	var cells = $SnakeMap.get_used_cells_by_id(id)
	for cell in cells:
		$SnakeMap.set_cell(cell.x,cell.y,-1)

func _input(event):
	if Input.is_action_just_pressed("ui_up"):
		if not snake_direction == Vector2(0,1):
			snake_direction = Vector2(0,-1)
	if Input.is_action_just_pressed("ui_down"):
		if not snake_direction == Vector2(0,-1):
			snake_direction = Vector2(0,1)
	if Input.is_action_just_pressed("ui_left"):
		if not snake_direction == Vector2(1,0):
			snake_direction = Vector2(-1,0)
	if Input.is_action_just_pressed("ui_right"):
		if not snake_direction == Vector2(-1,0):
			snake_direction = Vector2(1,0)
	if Input.is_action_just_pressed("ui_mute"):
		toggle_music()
func check_game_over():
	var head = snake_body[0]
	if head.x > 14 or head.x < 0 or head.y > 14 or head.y < 1:
		apple_nums.clear()
		reset()
		remove_all_apples()
		spawn_apples()
		$DeathFX.play()
	for segment in snake_body.slice(1,snake_body.size() - 1):
		if segment == head:
			$DeathFX.play()
			apple_nums.clear()
			reset()
			remove_all_apples()
			spawn_apples()

func reset():

	snake_body = [Vector2(4,7),Vector2(3,7),Vector2(2,7)]
	snake_direction = Vector2(1,0)
	get_tree().call_group("score_group","update_score",0)

func play_music():
	randomize()
	var song = randi() % 2
	music_player.stream = song_list[song]
	music_player.autoplay = true
	music_player.play()

func toggle_music():
	is_mute = !is_mute 

	if is_mute:
		music_player.volume_db = -80 
	else:
		music_player.volume_db = -12  
	
func _on_SnakeTick_timeout():
	if apples.size() == 0:
		spawn_apples()
	
	move_snake()
	draw_snake()
	check_apple_eaten()


func _on_Music_finished():
	play_music()
