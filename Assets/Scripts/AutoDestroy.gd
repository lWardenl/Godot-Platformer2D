extends Node

func _ready():
	yield(get_tree().create_timer(3), "timeout")
	self.queue_free()
