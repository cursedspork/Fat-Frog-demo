extends Node2D

signal died

@export_group("Jump Variables")
@export var jump_dist: float = 32 ## Global jump distance in pixels 
@export var jump_time: float = 1 ## Time to jump in seconds
@export var jump_curve: Curve ## Animation curve that determines the distance moved over time

@export var jump_audio: AudioStreamPlayer

@export_group("Death Variables")
@export var death_audio: AudioStreamPlayer


var last_time = -1000
var last_jump_pos: Vector2 = Vector2(0,0)
var is_waiting_for_jump: bool = false
var is_jumping: bool = false

var jump_dir: String = "up"


# Called when the node enters the scene tree for the first time.
func _ready():
	last_jump_pos.y = global_position.y + jump_dist

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# performs jump movement over time
	if Time.get_ticks_msec() - 1000 * jump_time < last_time:
		global_position.y = last_jump_pos.y - (jump_curve.sample((Time.get_ticks_msec() - last_time)/(1000 * jump_time)) * jump_dist)
	else:
		global_position.y = last_jump_pos.y - jump_dist
		is_jumping = false

func start_jump():
	jump_audio.play()
	last_time = Time.get_ticks_msec()
	last_jump_pos.y = global_position.y
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

# when hit die
func _on_area_2d_area_entered(_area):
	death_audio.play()
