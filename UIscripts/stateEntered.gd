extends Label

export var _target_path:NodePath
var _target
func _ready():
#	_target = get_node(_target_path)
	pass
#	subscribe_to_agent(_target)
#	_target.subscribe_agent_exited_state_signal(self,"exited")

func subscribe_to_agent(agent_node):
	agent_node.subscribe_agent_entered_state_signal(self,"entered")

func entered(state):
	set_text("entered %s"%state)
	

func exited(state):
	set_text("exited %s"%state)
	
