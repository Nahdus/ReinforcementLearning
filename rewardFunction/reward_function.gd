extends Node

export var agent_scene:PackedScene
export var executive_Agent:PackedScene
enum {RUN_FORWARD,JUMP_FORWARD,JUMP_BACKWARD,RUN_BACKWARD,STAY}
#var actions = [["run",1],["jump",1],["jump",-1],["run",-1],["idle",1]]
var action_list = [RUN_FORWARD,JUMP_FORWARD,JUMP_BACKWARD,RUN_BACKWARD,STAY]

#var agent


var number_of_actions = 5
var agent_list = []
var number_agents_per_batch = 50.0
var agentfreed = 0

var chromosome_reward = []

var purge_percentage = 50.0
#var number_of_genes = 12
var number_of_genes = 15
var generation = 0

var goals
var goalIndex = 0
var current_goal
var goalReached = false

var generationIndicator
var populationIndicator
var goalTouched = 0
var maxDistance = 0
var closestDistance = 9999
onready var initialPosition = $pos.position
onready var monitoring_node = $monitoring

var goal_positions = []
var complete_path = []
var simulationRunning = true


func subscribe():
	for agent in agent_list:
		agent.subscribe_agent_entered_state_signal(self,"state_entered")
		agent.subscribe_agent_exited_state_signal(self,"state_exited")	
		agent.subscribe_to_action_complete(self,"actioncomplete")


func remix_chromosomes(chromosome1,chromosome2):
	randomize()
	var splicePoint1 = rand_range(0,len(chromosome1)-1)
	var splicePoint2 = rand_range(floor(splicePoint1),len(chromosome1))
	var chromosome1Part = chromosome1.slice(splicePoint1,splicePoint2)
	var insert_pos = rand_range(0,len(chromosome2)-len(chromosome1Part))
	for each in chromosome1Part:
		chromosome2[floor(insert_pos)] = each
		insert_pos+=1
	return chromosome2

func mutate(chromosome):
	randomize()
	var probability = randf()
	if probability < 1.0/(number_agents_per_batch*number_of_genes):
		var geneIndex = floor(rand_range(0,len(chromosome)))
		var muatateToIndex = floor(rand_range(0,len(action_list)))
		chromosome[geneIndex] = action_list[muatateToIndex]
	return chromosome

func state_entered(state,agent):
	var transition = []
	transition.append(state)
	var reward = calculate_reward(agent.position)
	agent.add_to_state_table(transition,reward)
	
	

func state_exited(state,agent):
	pass
#	transition.append(state)
#	print_
func stop_simulation():
	simulationRunning = false

func activate_currentGoal(goalIndex):
	current_goal = goals[goalIndex]
	current_goal.subscribe_to_goal(self,"_on_goal_body_entered")
	current_goal.flash()

func load_env():
	goals = get_parent().get_node("goals").get_children()
	if goalIndex< len(goals):
		activate_currentGoal(goalIndex)
		agent_list=[]
		for i in range(number_agents_per_batch):
			var agent = agent_scene.instance()
			agent.set_position(initialPosition)
			agent_list.append(agent)
			add_child(agent)
#	
#	var goal = goals[goalIndex]
	
	maxDistance = initialPosition.distance_to(current_goal.position)
	


func cumulativeRewards(reward_list):
	var cumulative = 0
	var multiplier = float(number_of_genes)
	var idx = 1.0
	for each in reward_list:
		cumulative += each
	return cumulative


func actioncomplete(target):
#	print_debug(get_child_count())
	
	target.queue_free()
#	agentfreed+=1
#	print_debug(get_child_count())
#	if get_child_count() == 3:
#		agentfreed = 0
#		print_debug(get_children())
#		print_debug(get_child_count())
#		rerun(chromosome_reward)


func calculate_reward(pos):
	var distance = pos.distance_to(current_goal.position)
	if distance < closestDistance:
		closestDistance = distance
	$monitoring/farthestDistance.set_text("fathest Distance "+str(closestDistance))
	var grade = 0
	if distance<maxDistance:
		grade = (1-(distance/maxDistance))
	return -2*pow(grade,3)+3*pow(grade,2)
	
	
func execute_actions(agent,actions):
	agent.set_program(actions)
	agent.start()

func crate_random_action_table(steps):
	randomize()
	var program = []
	for i in range(0,steps,1):
		var actionIndex = floor(rand_range(0,len(action_list)))
		program.append(action_list[actionIndex])
#	print_debug(program)
	return program

func rand_run():
	generationIndicator = get_node("monitoring/generationIndicator")
	populationIndicator = get_node("monitoring/population")
	generationIndicator.set_text("generation "+str(generation))
	populationIndicator.set_text("population " + str(len(agent_list)))
	for agent in agent_list:
		var program = crate_random_action_table(number_of_genes)
		execute_actions(agent,program)



class reward_sorter:
	static func sort_ascending(a, b):
		# ascending is actually descensing reward because higher reward is farther from gooal
		return a[1]>b[1]




func sort_chromosomes(chromosome_reward_pair):
	chromosome_reward_pair.sort_custom(reward_sorter,"sort_ascending")
	return chromosome_reward_pair
	
func purge(chromosomes):
#	print_debug(len(chromosomes))
	var purge_after_index = floor(len(chromosomes)*(purge_percentage/100))
	return chromosomes.slice(0,purge_after_index)


func reproduce_remaining_pop(remaining_pop):
#	print_debug(len(remaining_pop))
	var reproducedPopulation = []
	for idx in range(len(remaining_pop)-1):
		var offspring1 = remix_chromosomes(remaining_pop[idx][0],remaining_pop[idx+1][0])
		var offspring2 = remix_chromosomes(remaining_pop[idx+1][0],remaining_pop[idx][0])
		offspring1 = mutate(offspring1)
		offspring2 = mutate(offspring2)
		reproducedPopulation.append(offspring1)
		reproducedPopulation.append(offspring2)
#	print_debug(len(reproducedPopulation))
#	print_debug(reproducedPopulation)
	return reproducedPopulation
		
func populate_offsprings(offsprings):
#	print_debug(len(offsprings))
	agent_list=[]
#	print_debug(offsprings)
	for _idx in range(len(offsprings)):
		var agent = agent_scene.instance()
		agent.set_position(initialPosition)
		agent_list.append(agent)
		add_child(agent)
#		execute_actions(agent,offsprings[_idx])
#	if len(offsprings)<number_agents_per_batch:
#		for i in range(number_agents_per_batch-len(offsprings)):
#			var agent = agent_scene.instance()
#			agent.set_position(initialPosition)
#			agent_list.append(agent)
#			add_child(agent)
	populationIndicator.set_text("Population "+str(len(agent_list)))	
	subscribe()
	for i in range(len(agent_list)):
		execute_actions(agent_list[i],offsprings[i])
#	execute_actions(agent,crate_random_action_table(number_of_genes))
			

	

		
func rerun(chromosome_reward):
	if goalReached:
		goalReached=false
		start()
		
	else:
		generation+=1
		generationIndicator = get_node("monitoring/generationIndicator")
		generationIndicator.set_text("generation "+str(generation))
	#	load_env()
	#	subscribe()
		var sorted_chromosomes = sort_chromosomes(chromosome_reward)
		var remaining_pop = purge(sorted_chromosomes)
		var offsprings = reproduce_remaining_pop(remaining_pop)
		
		populate_offsprings(offsprings)
	

func deploy_executiveAgent(complete_path):
	var execAgent = executive_Agent.instance()
	execAgent.set_position($pos.position)
	add_child(execAgent)
	execAgent.set_super_program(complete_path)
	var exec_goals = get_parent().get_node("goals").get_children()
	execAgent.assign_goals(exec_goals)
	execAgent.start()
	
#	var agent = agent_scene.instance()
#	agent.set_position(initialPosition)
#	agent_list.append(agent)
#	add_child(agent)
func save_initial_goal_position():
	for each in goals:
		goal_positions.append(each.position)
	
func reset_goal_positions():
	for idx in range(len(goals)):
		goals[idx].position = goal_positions[idx]

func start():
	if simulationRunning:
		load_env()
		save_initial_goal_position()
		subscribe()
		rand_run()
	else:
		reset_goal_positions()
		deploy_executiveAgent(complete_path)
		
		
func _ready():
	start()
	pass


func activate_next_goal():
	current_goal.unsubscribe_to_goal(self,"_on_goal_body_entered")
	initialPosition = current_goal.position
#	current_goal.set_collision_mask_bit(1,false)
	if goalIndex<len(goals)-1:
		goalIndex+=1
	else:
		stop_simulation()
#		activate_currentGoal(goalIndex)



func _on_goal_body_entered(body):
	complete_path.append(body.program)
	goalReached = true
	current_goal.position.x=body.position.x
	activate_next_goal()

	


func _on_agent_child_exiting_tree(node):
	var actions =[]
	var rewards = []
	if "agentBody" in node.get_name():
		var program = node.program
		var stateTable = node.stateTable
		for each in node.stateTable:
			actions.append(each[0][0])
			rewards.append(each[1])
		if actions!=program:
			print_debug(program)
			print_debug(actions)
	
	chromosome_reward.append([actions,cumulativeRewards(rewards)])
#	print_debug(get_child_count())
	if get_child_count() == 4:
		rerun(chromosome_reward)
		chromosome_reward=[]
