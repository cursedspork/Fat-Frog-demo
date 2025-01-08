extends Node2D

@export var frog: Node


# Called when the node enters the scene tree for the first time.
func _ready():
	frog.terrainTypes.append([48, "road"])
	frog.terrainTypes.append([-48, "river"])
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_frog_died():
	Engine.time_scale = 0
	pass # Replace with function body.
