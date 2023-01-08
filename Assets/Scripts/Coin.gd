extends Node2D

func _ready():
	$Area2D.connect("area_entered", self, "on_area_entered")
	
func on_area_entered(area2d):
	yield(get_tree().create_timer(0.01), "timeout")
	self.queue_free()
