extends Node2D
@export_group("Jump Values")
@export var jump_dist: float = 32 ## Global jump distance in pixels 
@export var jump_time: float = 1 ## Time to jump in seconds
@export var jump_curve: Curve ## Animation curve that determines the distance moved over time

var last_time = -1000
var last_jump_pos: float = 0
var is_waiting_for_jump: bool = false
var is_jumping: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	last_jump_pos = global_position.y + jump_dist

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# performs jump movement over time
	if Time.get_ticks_msec() - 1000 * jump_time < last_time:
		global_position.y = last_jump_pos - (jump_curve.sample((Time.get_ticks_msec() - last_time)/(1000 * jump_time)) * jump_dist)
	else:
		global_position.y = last_jump_pos - jump_dist
		is_jumping = false

func start_jump():
	last_time = Time.get_ticks_msec()
	last_jump_pos = global_position.y
	is_jumping = true

func _input(event):
	if event.is_action_pressed("jump"):
		if Time.get_ticks_msec() - last_time > 1000 * jump_time:
			start_jump()
		elif not is_waiting_for_jump and Time.get_ticks_msec() - last_time > (1000 * jump_time) / 2:
			is_waiting_for_jump = true
			await get_tree().create_timer((last_time + (1000 * jump_time) - Time.get_ticks_msec())/1000).timeout
			is_waiting_for_jump = false
			start_jump()
