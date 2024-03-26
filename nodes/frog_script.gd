extends Node2D
@export_group("Jump Values")
@export var dist: float = 32
@export var time: float = 1
@export var curve: Curve

var last_time = -1000
var last_jump_pos: float = 0
var waiting_for_jump: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	last_jump_pos = global_position.y + dist

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# performs jump movement over time
	if Time.get_ticks_msec() - 1000 * time < last_time:
		global_position.y = last_jump_pos - (curve.sample((Time.get_ticks_msec() - last_time)/(1000 * time)) * dist)
	else:
		global_position.y = last_jump_pos - dist
	


func start_jump():
	last_time = Time.get_ticks_msec()
	last_jump_pos = global_position.y


func _input(event):
	if event.is_action_pressed("jump"):
		if Time.get_ticks_msec() - last_time > 1000 * time:
			start_jump()
		elif not waiting_for_jump and Time.get_ticks_msec() - last_time > (1000 * time) / 2:
			waiting_for_jump = true
			await get_tree().create_timer((last_time + (1000 * time) - Time.get_ticks_msec())/1000).timeout
			waiting_for_jump = false
			start_jump()
