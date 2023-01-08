extends Control

var startingScene = preload("res://Assets/Scenes/Arena.tscn")

func _ready():
	$StartButton.connect("button_up",self,"_start_game")

func _start_game():
	get_node("/root").add_child(startingScene.instance())
	queue_free()
