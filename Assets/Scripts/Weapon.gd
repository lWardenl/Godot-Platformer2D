extends Node2D

func _ready():
	$Area2D.connect("body_entered",self,"_on_enter")

func _physics_process(_delta):
	position += transform.x * 7;

func _on_enter(_area2d):
	var audio = get_node("Audio")
	audio.get_parent().remove_child(audio)
	get_tree().root.add_child(audio)
	audio.play()
	yield(get_tree().create_timer(0.01), "timeout")
	self.queue_free()
