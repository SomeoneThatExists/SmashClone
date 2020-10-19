extends KinematicBody2D


const Gravity = 10
const JumpForce = -450
const Floor = Vector2(0,-1)


var velocity: Vector2
var UP = Vector2(0,1)
var run_speed = 14 * 14
var OnGround = false
var has_double_jumped = false


onready var Sprite = $Red_ghost_attack
onready var AnimP = $AnimationPlayer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

class player_controller:
	
	Vector2 velocity = Vector2(0, 0)
	
	# Called when the node enters the scene tree for the first time.
	func _ready():
		pass # Replace with function body.


	# Called every frame. 'delta' is the elapsed time since the previous frame.
	func _physics_process(delta):
		velocity.x = 0
		get_input()
		velocity = move_and_slide(velocity,Floor)
		
		if is_on_floor():
			OnGround = true
		else:
			OnGround = false
		
	func get_input():
		var left = Input.is_action_pressed('ui_left')
		var right = Input.is_action_pressed('ui_right')
		var jump = Input.is_action_just_pressed("ui_select")
		var attack = Input.is_action_pressed('E')
		
		if left:
			velocity.x -= run_speed
			Sprite.flip_h = false
			
		elif right:
			velocity.x += run_speed
			Sprite.flip_h = true	
		
		if jump:
			if OnGround == true:
				velocity.y = JumpForce
				has_double_jumped = false
				OnGround = false
			elif OnGround == false and has_double_jumped == false:
				velocity.y = JumpForce
				has_double_jumped = true
				
		if attack:
			AnimP.play('attack')
			AnimP.playback_speed = 5
		else:
			AnimP.play('idle')
			AnimP.playback_speed = 1
