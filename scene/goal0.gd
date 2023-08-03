extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var tween

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.

func subscribe_to_goal(target,function):
	if !is_connected("body_entered",target,function):
#		print_debug(target)
		connect("body_entered",target,function)
		
func unsubscribe_to_goal(target,function):
	if is_connected("body_entered",target,function):
#		print_debug(target)
		disconnect("body_entered",target,function)

func flash():
	tween  = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT).set_loops(100)
	tween.tween_property(self,"modulate",Color.red,1.0)
	tween.tween_property(self,"modulate",Color.white,1.0)
