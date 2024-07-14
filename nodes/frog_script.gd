extends Node2D

signal died

@export var idle_sprite: Sprite2D

@export var step_area: Area2D

@export_group("Jump Variables")
@export var jump_dist: float = 32 ## Global jump distance in pixels 
@export var jump_time: float = 1 ## Time to jump in seconds
@export var jump_curve: Curve ## Animation curve that determines the distance moved over time
@export var jump_audio: AudioStreamPlayer

@export_group("Death Variables")
@export var death_audio: AudioStreamPlayer

var last_time = -1000
var last_jump_pos: Vector2 = Vector2(0,0)
#var waiting_for_jump_dir: Vector2 = Vector2(0,0)
var is_jumping: bool = false
var jump_dir: Vector2 = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	last_jump_pos = global_position + jump_dir * jump_dist

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# performs jump movement over time
	if Time.get_ticks_msec() - 1000 * jump_time < last_time:
		global_position = last_jump_pos + (jump_curve.sample((Time.get_ticks_msec() - last_time)/(1000 * jump_time)) * jump_dist * jump_dir)
	else:
		global_position = last_jump_pos + (jump_dist * jump_dir)
		is_jumping = false
	if(step_area.get_overlapping_areas()):
		print(step_area.get_overlapping_areas())

func start_jump():
	jump_audio.play()
	last_time = Time.get_ticks_msec()
	last_jump_pos = global_position
	is_jumping = true
	idle_sprite.rotation = jump_dir.angle() + PI/2

func _input(event):
	if not is_jumping:
		if event.is_action("jump forward"):
			jump_dir = Vector2(0, -1)
			start_jump()
		if event.is_action("jump back"):
			jump_dir = Vector2(0, 1)
			start_jump()
		if event.is_action("jump left"):
			jump_dir = Vector2(-1, 0)
			start_jump()
		if event.is_action("jump right"):
			jump_dir = Vector2(1, 0)
			start_jump()

# when hit die
func _on_area_2d_area_entered(_area):
	death_audio.play()
	died.emit()
