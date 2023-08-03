extends Label

export var _target_path:NodePath
var _target

func _ready():
#	_target = get_node(_target_path)
	pass
#	subscribe_to_agent(_target)
	
#	_target.subscribe_agent_exited_state_signal(self,"exited")

func subscribe_to_agent(agent_node):
	agent_node.subscribe_agent_program_index_pointer(self,"change_index")

func change_index(index):
	set_text("program index %s"%index)
	


	
