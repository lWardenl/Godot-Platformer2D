extends Node2D

func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	position += transform.x * 7;
