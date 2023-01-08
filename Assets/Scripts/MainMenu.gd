extends Control

var startingScene = preload("res://Assets/Scenes/Arena.tscn")

func _process(delta):
	if($StartButton.is_pressed()):
		get_node("/root").add_child(startingScene.instance())
		self.queue_free()
