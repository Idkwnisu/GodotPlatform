extends Node2D

signal Area_Pig_Enter
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AttackArea_body_entered(body):
	print("Attack area body");
	emit_signal("Area_Pig_Enter");
	pass # Replace with function body.
