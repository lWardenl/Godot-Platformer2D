extends Node2D

func _physics_process(delta):
	position += transform.x * 7;
	$Area2D.connect("body_entered",self,"_on_enter")
	
func _on_enter(_area2d):
	self.queue_free()
