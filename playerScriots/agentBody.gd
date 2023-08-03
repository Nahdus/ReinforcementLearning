extends KinematicBody2D

var state_machine
var run_state
var jump_state 
var idle_state
var timer

enum {EXPLORE, EXECUTE}
var running = false

enum {RUN_FORWARD,JUMP_FORWARD,JUMP_BACKWARD,RUN_BACKWARD,STAY}
var actions = [["run",1],["jump",1],["jump",-1],["run",-1],["idle",1]]

var program 
var program_index = 0

var stateTable = []
var goalNode


signal agentEnteredState
signal agentExitedSignal
signal programIndexChanged
signal actionComplete



func add_to_state_table(transistion,reward):
	stateTable.append([transistion,reward])
	


func subscribe_agent_entered_state_signal(target,function):
	
	connect("agentEnteredState",target,function)
	
	
func subscribe_agent_exited_state_signal(target,function):
	
	connect("agentExitedSignal",target,function)
	

func subscribe_agent_program_index_pointer(target,function):
	connect("programIndexChanged",target,function)

func subscribe_to_action_complete(target,function):
	connect("actionComplete",target,function)

func subscribe_entry_exit(state):
	state.subscribeEntry(self,"entered_State")
	state.subscribeExit(self,"next_state")

func set_program(Action_program):
	if len(Action_program)!=12:
		print_debug(Action_program)
	program_index = 0
	program = Action_program

func _ready():
	state_machine = load("res://playerScriots/stateMachine/stateMachine.gd").new()
	state_machine.set_target(self)
	run_state =  load("res://playerScriots/stateMachine/states/run.gd").new()
	jump_state =  load("res://playerScriots/stateMachine/states/jump.gd").new()
	idle_state = load("res://playerScriots/stateMachine/states/idle.gd").new()
	state_machine.set_transistion_table(
		{
			"run":["run","jump","idle"],
			"jump":["idle","run","jump"],
			"idle":["run","jump","idle"]
	})
	subscribe_entry_exit(run_state)
	subscribe_entry_exit(jump_state)
	subscribe_entry_exit(idle_state)
	state_machine.add_state("run",run_state)
	state_machine.add_state("jump",jump_state)
	state_machine.add_state("idle",idle_state)
#	start()
	
func start():
	running = true
	var action = actions[program[program_index]]
	state_machine.set_initial_state(action[0],action[1])

func stop():
#	print_debug("stopped")
	running = false

func _physics_process(delta):
	if running:
		state_machine._physics_process(delta)

func entered_State(state,dir):
	emit_signal("agentEnteredState",actions.find([state,dir]),self)
	pass

func next_state(state,dir):
	emit_signal("agentExitedSignal",actions.find([state,dir]),self)
	program_index+=1
	if program_index>len(program)-1:
		program_index = 0
		emit_signal("actionComplete",self)
		stop()
		return
	emit_signal("programIndexChanged",program_index)
	var action = actions[program[program_index]]
	state_machine.transistion_to_state(action[0],action[1])
	

