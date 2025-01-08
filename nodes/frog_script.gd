extends Node2D

signal died

@export var idle_sprite: Sprite2D

@export var step_area: Area2D

@export_group("Jump Variables")
@export var jump_dist: float = 32 ## Global jump distance in pixels 
@export var jump_time: float = 1 ## Time to jump in seconds
@export var jump_curve: Curve ## Animation curve that determines the distance moved over time


@export_group("Audio Variables")
@export var jump_grass_audio: AudioStreamPlayer
@export var jump_road_audio: AudioStreamPlayer
@export var jump_log_audio: AudioStreamPlayer
@export var hit_car_audio: AudioStreamPlayer
@export var hit_water_audio: AudioStreamPlayer

var last_time = -1000
var last_jump_pos: Vector2 = Vector2(0,0)
#var waiting_for_jump_dir: Vector2 = Vector2(0,0)
var is_jumping: bool = false
var jump_dir: Vector2 = Vector2(0,0)
var is_dead: bool = false

var prev_float_pos: Vector2 = Vector2.ZERO

var terrainTypes: Array[Array] = []


# Called when the node enters the scene tree for the first time.
func _ready():
	last_jump_pos = global_position + jump_dir * jump_dist

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not is_jumping and not is_dead:
		if Input.is_action_pressed("jump forward"):
			jump_dir = Vector2(0, -1)
			start_jump()
		if Input.is_action_pressed("jump back"):
			jump_dir = Vector2(0, 1)
			start_jump()
		if Input.is_action_pressed("jump left"):
			jump_dir = Vector2(-1, 0)
			start_jump()
		if Input.is_action_pressed("jump right"):
			jump_dir = Vector2(1, 0)
			start_jump()

	
	
	# performs jump movement over time
	if is_dead:
		return
	
	if Time.get_ticks_msec() - 1000 * jump_time < last_time: #is not jumping
		global_position = last_jump_pos + (jump_curve.sample((Time.get_ticks_msec() - last_time)/(1000 * jump_time)) * jump_dist * jump_dir)
	else:
		if is_jumping:#stop jumping
			global_position = last_jump_pos + (jump_dist * jump_dir)
		if(step_area.get_overlapping_areas() and step_area.get_overlapping_areas().front().is_in_group("FloatingArea")):
			if prev_float_pos == Vector2.ZERO:
				prev_float_pos = step_area.get_overlapping_areas().front().global_position
			else:
				global_position = global_position + (step_area.get_overlapping_areas().front().global_position - prev_float_pos)
				prev_float_pos = step_area.get_overlapping_areas().front().global_position
		else:
			if is_jumping && get_curr_surface() == "river":
				die("water")
				visible = false
		is_jumping = false

func start_jump():
	if get_curr_surface() == "road":
		jump_road_audio.play()
	elif get_curr_surface() == "river":
		jump_log_audio.play()
	else:
		jump_grass_audio.play()
	
	last_time = Time.get_ticks_msec()
	last_jump_pos = global_position
	is_jumping = true
	prev_float_pos = Vector2.ZERO
	idle_sprite.rotation = jump_dir.angle() + PI/2

func get_curr_surface():
	for terr in terrainTypes:
		if abs(terr[0] - global_position.y) < jump_dist/2:
			return terr[1]
	return "grass"

func die(d_type):
	if(d_type == "car"):
		hit_car_audio.play()
	if(d_type == "water"):
		hit_water_audio.play()
	is_dead = true
	died.emit()

# when hit die
func _on_area_2d_area_entered(_area):
	die("car")
