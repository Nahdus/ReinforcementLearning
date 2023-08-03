extends "res://playerScriots/stateMachine/states/motion.gd"


var _state_name = "run"
var _target
var _machine
var _dir = 1
var _timer
var _subscriber = []
var stateActive = false

func set_target(target):
	_target = target
	
func set_machine(machine):
	_machine = machine

func _enter(dir):
	stateActive=true
	_timer = Timer.new()
	_timer.connect("timeout",self,"_exit")
	_timer.set_wait_time(airTime)
	_timer.set_one_shot(true)
	_target.add_child(_timer)
	_timer.start()
	reload_Speed()
	_dir = dir
	emit_signal("stateEntry",_state_name,_dir)
	
func _exit():
	stateActive = false
	_timer.queue_free()
	emit_signal("stateExit",_state_name,_dir)
	



func update(delta):
	if stateActive:
		vertical_speed = -gravity*delta
		_target.move_and_slide(Vector2(_dir*horizontal_speed,vertical_speed),Vector2.UP)
	
