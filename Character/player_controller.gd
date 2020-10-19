extends KinematicBody2D

class_name player_controller

export (float) var gravity = 800
export (float) var max_fall_speed = 350
export (float) var JumpForce = -550
export (float) var run_speed = 350
export (int) var max_jumps = 4

#onready var Sprite = $Red_ghost_attack
onready var AnimP = $AnimationPlayer

const Down = Vector2(0, 1)
const Up = Vector2(0, -1)

var OnGround = false
var num_jumps = 4

var velocity: Vector2

enum Action {NONE, JUMP, GROUNDED_ATTACK_0}

var BufferedAction = Action.NONE
var CurrentAction = Action.NONE

const BUFFER_DURATION = 0.3
var buffer_timer = 0

# Influence fron gravity, jumping, knockback, etc.
var physics_influence: Vector2

#input movement
var move_input: Vector2
var input_influence: Vector2
export var air_acceleration = 800
export var ground_acceleration = 1400
var facingRight = false

var awaitingJump = false

# Called when the node enters the scene tree for the first time.
func _ready():
	AnimP.current_animation = "idle_walk"

func _process(delta):
	
	# Execute the buffered action, if possible (if there is an action buffered
	if BufferedAction == Action.GROUNDED_ATTACK_0 and can_interrupt():
		AnimP.animation_set_next("grounded_attack_0", "idle_walk")
		AnimP.play("grounded_attack_0")
		CurrentAction = BufferedAction
		BufferedAction = Action.NONE
	
	elif BufferedAction == Action.JUMP and can_interrupt():
		if num_jumps > 0:
			num_jumps = num_jumps - 1
			AnimP.animation_set_next("jump", "idle_walk")
			AnimP.play("jump")
			CurrentAction = BufferedAction
			BufferedAction = Action.NONE
	
	if BufferedAction != Action.NONE:
		buffer_timer += delta
		
		if buffer_timer >= BUFFER_DURATION:
			BufferedAction = Action.NONE
			buffer_timer = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
		# Check if character is grounded, and execute grounded/midair functions
	if is_on_floor():
		process_on_ground(_delta)
	else:
		process_in_air(_delta)
	
	if awaitingJump:
		jump()
		awaitingJump = false
	
	process_input_influence(_delta)
	process_physics_influence(_delta)
	
	move_and_slide(assemble_velocity(), Up)

func process_input_influence(_delta):	
	
	# -1 for left, 1 for right, 0 for no input
	var inputDir = sign(move_input.x)
	
	# Define what our current acceleration is
	var acc
	if OnGround:
		acc = ground_acceleration
	else:
		acc = air_acceleration
	
	if inputDir > 0:
		set_face_dir(true)
	if inputDir < 0:
		set_face_dir(false)
	
	# if there is no input, or if input is in the opposite direction we're currently moving,
	# accelerate in the opposite direction we're moving, slowing the character down until coming to rest
	if inputDir != sign(input_influence.x):
		var _sign = sign(input_influence.x)
		input_influence.x -= _sign * acc * _delta
		if _sign != sign(input_influence.x):
			input_influence.x = 0
	
	# accelerate toward run_speed in the direction being held over time
	input_influence += move_input * acc * _delta
	
	# clamp input influence to positive and negative max speed
	input_influence.x = clamp(input_influence.x, -run_speed, run_speed)

func process_physics_influence(_delta):
	if not OnGround:
		physics_influence.y += gravity * _delta
		physics_influence.y = clamp(physics_influence.y, -INF, max_fall_speed)
	else:
		physics_influence.y = 1

# returns the sum of all movement vectors
func assemble_velocity():
	return physics_influence + input_influence

func set_move_input(var direction):
	move_input.x = direction.x

func process_on_ground(_delta):
	# If we weren't on the ground in the previous physics process, call on_landing().
	if not OnGround:
		on_landing()
	OnGround = true

func process_in_air(_delta):
	OnGround = false

func jump():
	physics_influence.y = JumpForce
	OnGround = false

func gain_jumps(jumps):
	num_jumps += jumps
	if num_jumps > max_jumps:
		num_jumps = max_jumps

func on_landing():
	gain_jumps(max_jumps)

func set_face_dir(facingRight):
	self.facingRight = facingRight
	$Sprite.flip_h = facingRight

func can_interrupt():
	print("Can Interrupt? " + str(CurrentAction == Action.NONE))
	return CurrentAction == Action.NONE

#####																	#####
##### Functions for bufferring actions (called by player_input_handler) #####
#####																	#####

func buffer_jump():
	BufferedAction = Action.JUMP
		
func buffer_attack():
	BufferedAction = Action.GROUNDED_ATTACK_0

#####																						#####
##### Functions to be called by the AnimationPlayer, using the method call animation track  #####
#####																						#####

func anim_on_jump_end():
	awaitingJump = true
	CurrentAction = Action.NONE

func anim_on_attack_end():
	CurrentAction = Action.NONE


#func get_input():
#	var left = Input.is_action_pressed('ui_left')
#	var right = Input.is_action_pressed('ui_right')
#	var jump = Input.is_action_just_pressed("ui_select")
#	var attack = Input.is_action_pressed('E')
#
#	if left:
#		velocity.x -= run_speed
#		Sprite.flip_h = false
#
#	elif right:
#		velocity.x += run_speed
#		Sprite.flip_h = true	
#
#	if jump:
#		if OnGround == true:
#			velocity.y = JumpForce
#			has_double_jumped = false
#			OnGround = false
#		elif OnGround == false and has_double_jumped == false:
#			velocity.y = JumpForce
#			has_double_jumped = true
#
#	if attack:
#		AnimP.play('attack')
#		AnimP.playback_speed = 5
#	else:
#		AnimP.play('idle')
#		AnimP.playback_speed = 1
