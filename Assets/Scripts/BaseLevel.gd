extends Node

var playerScene = preload("res://Assets/Scenes/Player.tscn")
var spawnPosition = Vector2.ZERO
var currentPlayerNode = null

func _ready():
	spawnPosition = $Player.global_position
	register_player($Player)
	
func register_player(player):
	currentPlayerNode = player
	currentPlayerNode.connect("died", self, "on_player_died")
	
func create_player():
	var playerInstance = playerScene.instance()
	add_child_below_node(playerInstance, currentPlayerNode)
	register_player(playerInstance)
	
func on_player_died():
	currentPlayerNode.queue_free()
	create_player()
