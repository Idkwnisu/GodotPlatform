extends KinematicBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var gravity: float;

export var maxSpeed = Vector2(80,300);

var playback : AnimationNodeStateMachinePlayback;

var sprite;

var _velocity: Vector2 = Vector2.ZERO;

export var horizontalSpeed: float =  5;

export var jumpSpeed = -600;

const FLOOR_NORMAL: Vector2 = Vector2.UP

var jumping = false;

var groundTime = 0.1;

var attackTime = 0.3;

var startAttack = 0;

var attacking = false;

var lastGround = 0;

var AttackLeft: Node2D;
var AttackRight: Node2D;

var AttackCollision: CollisionShape2D;

var goingRight : bool = true;

export var health: int = 3;


# Called when the node enters the scene tree for the first time.
func _ready():
	playback =  get_node("Tree").get("parameters/playback");
	sprite = get_node("Pivot");
	AttackLeft = get_node("../AttackLeft");
	AttackRight = get_node("../AttackRight");
	AttackCollision = get_node("AttackArea/AttackCollision");

func _process(delta):
	if attacking:
		startAttack += delta;
		if startAttack > attackTime:
			AttackCollision.set_disabled(true);
			attacking = false;
			playback.travel("KingIdle");
	lastGround += delta;
	if lastGround > groundTime and not attacking:
		if Input.is_action_pressed("Left_Move") or Input.is_action_pressed("Right_Move") and not jumping:
			playback.travel("KingRun");
		elif not jumping:
			playback.travel("KingIdle");
		
	if Input.is_action_pressed("Left_Move") and not Input.is_action_pressed("Right_Move"):
		goingRight = false;
		sprite.scale = Vector2(-3,3);
	elif not Input.is_action_pressed("Left_Move") and Input.is_action_pressed("Right_Move"):
		goingRight = true;
		sprite.scale = Vector2(3,3);
		
	if Input.is_action_just_pressed("Attack") and not attacking:
		playback.travel("KingAttack");
		attacking = true;
		AttackCollision.set_disabled(false);
		if goingRight:
			AttackCollision.position = AttackRight.position;
		else:
			AttackCollision.position = AttackLeft.position;
		startAttack = 0;
	
func _physics_process(delta):
	
	
	var horizontal = Input.get_action_strength("Right_Move") - Input.get_action_strength("Left_Move")
	var movement;
	if _velocity.y < 0:
		movement = Vector2(horizontal*horizontalSpeed,2*gravity);
	else:
		movement = Vector2(horizontal*horizontalSpeed,2*gravity);
		
		
			
	if jumping and is_on_floor():
		jumping = false;
		playback.travel("KingGround");
		lastGround = 0;
		
		
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		_velocity.y = jumpSpeed;
		jumping = true;
		playback.travel("KingJump");

	if Input.is_action_just_released("Jump") and _velocity.y < 0:
		_velocity.y = 0;
	
	
	_velocity += movement;
	
		
	if _velocity.x > maxSpeed.x:
		_velocity.x = maxSpeed.x;
	if _velocity.x < -maxSpeed.x:
		_velocity.x = -maxSpeed.x;
		
	if _velocity.y > maxSpeed.y:
		_velocity.y = maxSpeed.y;
	if _velocity.y < -maxSpeed.y:
		_velocity.y = -maxSpeed.y;
		
	if horizontal == 0 or (horizontal < 0 and _velocity.x > 0) or (horizontal > 0 and _velocity.x < 0) :
		_velocity *= Vector2(0.7,1);
	
	_velocity = move_and_slide(_velocity, FLOOR_NORMAL);


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



func _on_Player_Area_Pig_Enter():
	health = health - 1;
	#animation
	#spinta
	#salute
	#check if health <0
