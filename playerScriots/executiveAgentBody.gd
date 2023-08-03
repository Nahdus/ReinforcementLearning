extends KinematicBody2D

var state_machine
var run_state
var jump_state 
var idle_state
var timer
var goals =[]
var goalIndex = 0
enum {EXPLORE, EXECUTE}
var running = false
enum {RUN_FORWARD,JUMP_FORWARD,JUMP_BACKWARD,RUN_BACKWARD,STAY}
var actions = [["run",1],["jump",1],["jump",-1],["run",-1],["idle",1]]

var super_program

var program
var program_index = 0
var super_program_index = 0


#var stateTable = []
#var goalNode


signal agentEnteredState
signal agentExitedSignal
signal programIndexChanged
signal actionComplete


#
#func add_to_state_table(transistion,reward):
#	stateTable.append([transistion,reward])


func assign_goals(_goals):
#	goals[goalIndex].set_collision_mask_bit(1,true)
	goals = _goals
	goals[goalIndex].subscribe_to_goal(self,"goal_reached")
	

func next_goal():
	goals[goalIndex].unsubscribe_to_goal(self,"goal_reached")
	goalIndex+=1
	goals[goalIndex].subscribe_to_goal(self,"goal_reached")
	if goalIndex==len(goals):
		stop()
	
	
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

func set_super_program(_super_program):
	super_program = _super_program

func set_program(Action_program):
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
#	set_program(super_program[super_program_index])
#	start()
	
func start():
	running = true
	program = super_program[super_program_index]
	var action = actions[program[program_index]]
	state_machine.set_initial_state(action[0],action[1])
	
func stop():
	running = false


func _physics_process(delta):
	if running:
		state_machine._physics_process(delta)

func entered_State(state,dir):
#	print_debug(program_index)
	emit_signal("agentEnteredState",actions.find([state,dir]),self)
	pass

func next_state(state,dir):
	emit_signal("agentExitedSignal",actions.find([state,dir]),self)
	program_index+=1
	if program_index>len(program)-1:
		program_index = 0
		if super_program_index<len(super_program)-1:
			super_program_index+=1
			emit_signal("actionComplete",self)
			set_program(super_program[super_program_index])
		else:
			stop()
			
#		return
#	program_index = 0
	emit_signal("programIndexChanged",program_index)
	var action = actions[program[program_index]]
	state_machine.transistion_to_state(action[0],action[1])
	pass
	
func goal_reached(body):
	
	if super_program_index<len(super_program)-1:
#		stop()
		get_tree().paused = true
		state_machine.transistion_to_state(actions[STAY][0],actions[STAY][1])
		if program_index<len(program)-1:
			program = program.slice(0,program_index+1)
			program[program_index+1] = STAY
		else:
			pass
		get_tree().paused = false
#		skip_program = true
#		super_program_index+=1
#		program_index = 0
		next_goal()
#		start()
	else:
		stop()

