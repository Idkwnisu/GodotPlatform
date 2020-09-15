extends KinematicBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const RUN:int = 0;
const ATTACK:int = 1;


var target: Node2D;

var lastTargetLeft: bool = false;

var leftTarget: Node2D;

var rightTarget: Node2D;

var needNewTarget: bool = true;

var targetingPlayer: bool = false;

export var attackDistance = 100;

var playerNode: Node2D;

export var aggroDistance: float = 30.0;

export var gravity: float;

export var maxSpeed = Vector2(80,100);

var playback : AnimationNodeStateMachinePlayback;

var sprite;

var _velocity: Vector2 = Vector2.ZERO;

export var horizontalSpeed: float =  5;

export var jumpSpeed = -600;

export var health = 3;

const FLOOR_NORMAL: Vector2 = Vector2.UP

var jumping = false;

var groundTime = 0.1;

var lastGround = 0;

var current_animation:int = RUN;

var hitted : bool = false;

var lastHit = 0;

var hitTime = 0.3;

var AttackCollision: CollisionShape2D;

var LeftAttack: Node2D;

var RightAttack: Node2D;

var dead : bool = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	playback = get_node("Tree").get("parameters/playback");
	sprite = get_node("Pivot");
	leftTarget = get_node("../LeftBound");
	rightTarget = get_node("../RightBound");
	playerNode = get_node("../../Player/KingBody/Pivot");
	AttackCollision = get_node("AttackArea/AttackCollision");
	LeftAttack = get_node("LeftAttack");
	RightAttack = get_node("RightAttack");

	
func _physics_process(delta):

	if not hitted:
		update_target();
		var hor_direction = get_horizontal_direction();
		var hor = hor_direction*horizontalSpeed;
		if not is_on_floor():
			hor = 0;
		var movement: Vector2 = Vector2(hor,gravity);
		_velocity += movement;
	
		if get_global_position().distance_to(playerNode.get_global_position()) < attackDistance:
			_velocity.x = 0;
	
			
		if _velocity.x > maxSpeed.x*( 2.0 if targetingPlayer else 1.0) :
			_velocity.x = maxSpeed.x*( 2.0 if targetingPlayer else 1.0) ;
		if _velocity.x < -maxSpeed.x*( 2.0 if targetingPlayer else 1.0) :
			_velocity.x = -maxSpeed.x*( 2.0 if targetingPlayer else 1.0) ;
				
		if _velocity.y > maxSpeed.y:
			_velocity.y = maxSpeed.y;
		if _velocity.y < -maxSpeed.y:
			_velocity.y = -maxSpeed.y;
		
		if position.distance_to(target.position) < 30 and not targetingPlayer:
			needNewTarget = true;
		if not dead:
			if hor_direction > 0:
				sprite.scale = Vector2(-3,3);
			else:
				sprite.scale = Vector2(3,3);
			
	if dead:
		_velocity.x = 0;	
	_velocity = move_and_slide(_velocity, FLOOR_NORMAL);
	
func _process(delta):
	
	if not dead:
		if hitted:
			lastHit += delta;
			if lastHit > hitTime:
				hitted = false;
				playback.travel("Run")
				current_animation = RUN;
		if not hitted:
			if get_global_position().distance_to(playerNode.get_global_position()) < attackDistance:
				if current_animation == RUN:
					playback.travel("Attack");
					current_animation = ATTACK;
					AttackCollision.set_disabled(false);
					if playerNode.get_global_position().x > get_global_position().x:
						AttackCollision.position = RightAttack.position;
					else:
						AttackCollision.position = LeftAttack.position;
			else:
				if current_animation == ATTACK:
					current_animation = RUN;
					playback.travel("Run");
					AttackCollision.set_disabled(true);
	
func get_horizontal_direction() -> float:
	if get_global_position().x > target.get_global_position().x:
		return -1.0;
	else:
		return 1.0;
	
func update_target():
	if get_global_position().distance_to(playerNode.get_global_position()) < aggroDistance:
		target = playerNode;
		targetingPlayer = true;
	elif needNewTarget or targetingPlayer:
		if lastTargetLeft:
			target = rightTarget;
			lastTargetLeft = false;
			needNewTarget = false;
			targetingPlayer = false;
		else:
			target = leftTarget;
			lastTargetLeft = true;
			needNewTarget = false; 	
			targetingPlayer = false;
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AttackArea_body_entered(body):
	if not dead:
		AttackCollision.set_disabled(true);
		health = health -1;
		if(health < 0):
			playback.travel("Death");
			dead = true;
			
		else:
			playback.travel("Hit");
			hitted = true;
			lastHit = 0.0;
		if playerNode.get_global_position().x > get_global_position().x:
			_velocity += Vector2(-200,-50);
		else:
			_velocity += Vector2(200,-50);
