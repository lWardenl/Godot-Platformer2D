extends Node

var playerScene = preload("res://Assets/Scenes/Player.tscn")

func _ready():
	register_player($Player)
	register_player($Player2)
	
func register_player(player):
	player.connect("died", self, "on_player_died")
	
func create_player(suffix,position):
	var playerInstance = playerScene.instance()
	get_node("/root/BaseLevel").add_child(playerInstance)
	register_player(playerInstance)
	playerInstance.position = position
	playerInstance.playerSuffix = suffix
	
func on_player_died(suffix,player):
	player.queue_free()
	create_player(suffix,player.position)
