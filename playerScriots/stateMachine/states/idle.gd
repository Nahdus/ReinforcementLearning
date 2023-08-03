extends "res://playerScriots/stateMachine/states/motion.gd"



var _state_name = "idle"
var _target
var _machine
var _dir = 1
var _timer
var current_pos = 0
var stateActive = false


func set_target(target):
	_target = target
	
func set_action_index(idx):
	stateActive = idx

func set_machine(machine):
	_machine = machine

func _enter(dir):
	stateActive = true
	current_pos = _target.get_global_position().x
	vertical_speed = 0
	_timer = Timer.new()
	_target.add_child(_timer)
	_timer.connect("timeout",self,"_exit")
	_timer.set_one_shot(true)
	_timer.set_wait_time(airTime)
	_timer.start()
	emit_signal("stateEntry",_state_name,dir)
	
	
func _exit():
	_timer.queue_free()
	emit_signal("stateExit","idle",_dir)

func update(delta):
	if stateActive:
		vertical_speed = vertical_speed -gravity*delta
		_target.move_and_slide(Vector2(0.0,vertical_speed),Vector2.UP)
	if _target.is_on_floor():
		stateActive = false
