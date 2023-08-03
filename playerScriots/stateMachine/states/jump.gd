extends "res://playerScriots/stateMachine/states/motion.gd"


var _state_name = "jump"
var _target
var _machine
var _dir =1
var stateActive = false


func set_target(target):
	_target = target
	
func set_machine(machine):
	_machine = machine
	
func _enter(dir):
	stateActive=true
	reload_Speed()
	_dir = dir
	emit_signal("stateEntry","jump",_dir)
	
func _exit():
	stateActive=false
	emit_signal("stateExit","jump",_dir)


func update(delta):
	if stateActive:
		vertical_speed = vertical_speed-gravity*delta
		_target.move_and_slide(Vector2(_dir*horizontal_speed,vertical_speed),Vector2.UP)
		if _target.is_on_floor():
			stateActive=false
			_exit()
