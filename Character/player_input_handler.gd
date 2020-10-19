extends Node2D

class_name player_input_handler

onready var player = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(_delta):
	var input_axis = Vector2(0, 0)
	
	if Input.is_action_pressed('ui_left'):
		input_axis.x -= 1
	
	if Input.is_action_pressed('ui_right'):
		input_axis.x += 1
	
	if Input.is_action_pressed('ui_down'):
		input_axis.y -= 1
	
	if Input.is_action_pressed('ui_up'):
		input_axis.y += 1
	
	player.set_move_input(input_axis)
	
	if Input.is_action_just_pressed('player_jump'):
		player.buffer_jump()
	
	if(Input.is_action_just_pressed('E')):
		player.buffer_attack()
	
