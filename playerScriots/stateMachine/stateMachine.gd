extends Node

var _target
var _transistion_table
var _current_state
var _states = {}
var running  = false

func set_target(target):
	_target = target

	
func get_target(target):
	return _target
	
func state_execution_complete():
	pass
	
func add_state(state_name,state):
	state.set_target(_target)
	state.set_machine(self)
	_states[state_name]=state

func set_initial_state(state,dir):
	_states[state]._enter(dir)
	_set_current_state(state)

func set_transistion_table(table):
	_transistion_table = table

func transistion_to_state(state,dir):
	if state in _transistion_table[_current_state]:
		_states[state]._enter(dir)
		_set_current_state(state)
	else:
		pass
	
func _set_current_state(state):
	_current_state = state
	
	
func _physics_process(delta):
	_states[_current_state].update(delta)
