extends KinematicBody2D

var gravity = 1000
var velocity = Vector2.ZERO
var horizontalAcceleration = 2000
var moveSpeed = 140

var jumpForce = 360
var fallMultiplier = 4

var hasDoubleJump = false

var shootTime = 0.5
var currentShot = 0
var startingPosition = position
var invinsibilityTime = 1

var winUI = preload("res://Assets/Scenes/WinUI.tscn")
var menuScene = preload("res://Assets/Scenes/WinUI.tscn")
var weaponScene
var initRot
var isDead = false
var hasCheese = false

export var playerSuffix = "0"
export var playerIndex = 0
export var weaponPath = "res://Assets/Scenes/Banana.tscn"
export var playerLives = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	$"Hazard Area".connect("area_entered", self, "on_hazard_area_entered")
	$"Pickup Area".connect("area_entered", self, "on_pickup")
	startingPosition = position
	initRot = rotation
	weaponScene = load(weaponPath)
	menuScene = load("res://Assets/Scenes/MainMenu.tscn")
	
	# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	handle_animations()

	if (isDead):
		return
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



func get_movement_vector():
	var moveVector = Vector2.ZERO
	moveVector.x = Input.get_action_strength("move_right" + playerSuffix) - Input.get_action_strength("move_left" + playerSuffix)
	moveVector.y = -1 if Input.is_action_just_pressed("jump" + playerSuffix) else 0
	return moveVector
	
func handle_animations():
	var moveVector = get_movement_vector()

	if (isDead):
		if (hasCheese):
			$AnimatedSprite.play("Revive")
		else:
			$AnimatedSprite.play("Death")
	elif(!is_on_floor()):
		$AnimatedSprite.play("Jump")
		$AnimatedSprite.rotate(PI/15)
	elif(currentShot > 0):
		$AnimatedSprite.play("Attack")
		if ($AnimatedSprite.rotation != initRot):
			$AnimatedSprite.rotate(PI/12)
			if (wrapf($AnimatedSprite.rotation - initRot, 0, TAU) < 0.3):
					$AnimatedSprite.rotation = initRot
	elif(moveVector.x != 0):
		$AnimatedSprite.play("Run")
		if ($AnimatedSprite.rotation != initRot):
			$AnimatedSprite.rotate(PI/12)
			if (wrapf($AnimatedSprite.rotation - initRot, 0, TAU) < 0.3):
					$AnimatedSprite.rotation = initRot
	else:
		$AnimatedSprite.play("Idle")
		if ($AnimatedSprite.rotation != initRot):
			$AnimatedSprite.rotate(PI/12)
			if (wrapf($AnimatedSprite.rotation - initRot, 0, TAU) < 0.3):
					$AnimatedSprite.rotation = initRot
	
	if(moveVector.x != 0):
		$AnimatedSprite.flip_h = true if moveVector.x > 0 else false

func on_hazard_area_entered(_area2d):
	if (invinsibilityTime > 0):
		return
	if (!hasCheese):
		playerLives -= 1
		if (playerLives < 1):
			var winScreen = winUI.instance()
			get_tree().root.add_child(winScreen)
			winScreen.get_node("Text").bbcode_text = "[center]Player " + str(- playerIndex + 2) + " Wins![/center]"
			get_tree().paused = true
			yield(get_tree().create_timer(1.0), "timeout")
			get_tree().paused = false
			winScreen.queue_free()
			get_node("/root/BaseLevel").queue_free()
			get_node("/root").add_child(menuScene.instance())
			return
	isDead = true
	yield(get_tree().create_timer(1.0), "timeout")
	isDead = false
	if (!hasCheese):
		position = startingPosition
	invinsibilityTime = 1
	if (hasCheese):
		hasCheese = false

func shoot():
	if (currentShot > 0):
		return
	
	currentShot = shootTime

	var weapon = weaponScene.instance()
	get_node("/root/BaseLevel").add_child(weapon)
	weapon.position = position - Vector2(0,10)
	weapon.rotation = $AnimatedSprite.rotation
	if (!$AnimatedSprite.flip_h):
		weapon.rotate(PI)

	weapon.position += weapon.transform.x * 35

func on_pickup(_area2d):
	hasCheese = true
