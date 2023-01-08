extends KinematicBody2D

signal died

var gravity = 1000
var velocity = Vector2.ZERO
var horizontalAcceleration = 2000
var moveSpeed = 140

var jumpForce = 360
var fallMultiplier = 4

var hasDoubleJump = false

var shootTime = 1
var currentShot = 0
var startingPosition = position
var invinsibilityTime = 1

var bananaScene = preload("res://Assets/Scenes/Banana.tscn")

export var playerSuffix = "0"

# Called when the node enters the scene tree for the first time.
func _ready():
	$"Hazard Area".connect("area_entered", self, "on_hazard_area_entered")
	startingPosition = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var moveVector = get_movement_vector()
	
	velocity.x += moveVector.x * horizontalAcceleration * delta
	
	if(moveVector.x == 0):
		velocity.x = lerp(0, velocity.x, pow(2, -50 * delta))
		
	velocity.x = clamp(velocity.x, -moveSpeed, moveSpeed)
	
	if (moveVector.y < 0 && (is_on_floor() || !$CoyoteTimer.is_stopped() || hasDoubleJump))  :
		velocity.y = moveVector.y * jumpForce
		if(!is_on_floor() && $CoyoteTimer.is_stopped()):
			hasDoubleJump = false;
		$CoyoteTimer.stop()
		
	if(velocity.y < 0 && !Input.is_action_pressed("jump" + playerSuffix)):
		velocity.y += gravity * fallMultiplier * delta
	else:
		velocity.y += gravity * delta
		
	var wasOnFloor = is_on_floor()
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if(wasOnFloor && !is_on_floor()):
		$CoyoteTimer.start()
		
	if(is_on_floor()):
		hasDoubleJump = true

	if (currentShot > 0):
		currentShot -= delta

	if (invinsibilityTime > 0):
		invinsibilityTime -= delta

	if (Input.is_action_just_pressed("shoot" + playerSuffix)):
		shoot()

	handle_animations()


func get_movement_vector():
	var moveVector = Vector2.ZERO
	moveVector.x = Input.get_action_strength("move_right" + playerSuffix) - Input.get_action_strength("move_left" + playerSuffix)
	moveVector.y = -1 if Input.is_action_just_pressed("jump" + playerSuffix) else 0
	return moveVector
	
func handle_animations():
	var moveVector = get_movement_vector()
	
	if(!is_on_floor()):
		$AnimatedSprite.play("Jump")
	elif(currentShot > 0):
		$AnimatedSprite.play("Attack")
	elif(moveVector.x != 0):
		$AnimatedSprite.play("Run")
	else:
		$AnimatedSprite.play("Idle")
	
	if(moveVector.x != 0):
		$AnimatedSprite.flip_h = true if moveVector.x > 0 else false

func on_hazard_area_entered(area2d):
	if (invinsibilityTime > 0):
		return
	position = startingPosition
	invinsibilityTime = 1

func shoot():
	if (currentShot > 0):
		return
	
	currentShot = shootTime

	var banana = bananaScene.instance()
	get_node("/root/BaseLevel").add_child(banana)
	banana.global_position = position - Vector2(0,10)
	if (!$AnimatedSprite.flip_h):
		banana.position.x -= 18
		banana.rotate(PI)
	else:
		banana.position.x += 18
