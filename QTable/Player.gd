extends StaticBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(String) var fileName

var map
var starting = true

var seconds = 0
var cur_pos = [0,0]
var prev_pos = []
var environment_matrix = {}
var q_matrix = {}
var win_loss_states = []
var start_states = []
var discount = 0
var learning_rate = 0
var numtrain = 0
var count = 0
var agent_start = "random"
var train = true

# Called when the node enters the scene tree for the first time.
func _ready():
	fileName = Global.fileName
	var data = []
	
	var file = File.new()
	file.open(fileName, file.READ)
	
	map = JSON.parse(file.get_as_text()).result
	
	var size = [int(map["size"][0]),int(map["size"][1])]
	win_loss_states = []
	for state in map["win_loss_states"]:
		win_loss_states.append([int(state[0]),int(state[1])])
	discount = map["discount"]
	learning_rate = map["learning_rate"]
	numtrain = map["numtrain"]
	agent_start = map["agent_start"]
	if String(agent_start) != "random":
		agent_start = [int(agent_start[0]),int(agent_start[1])]
	data = map["data"]
	for datum in data:
		datum[0] = [int(datum[0][0]),int(datum[0][1])]
	
	for i in range(size[0]):
		for j in range(size[1]):
			var tile = [0,0,0,0]
			
			if i == 0:
				tile[0] = null
			if j+1 == size[1]:
				tile[1] = null
			if i+1 == size[0]:
				tile[2] = null
			if j == 0:
				tile[3] = null
				
			environment_matrix[[int(i),int(j)]] = tile
			
			q_matrix[[i,j]] = [0,0,0,0]
			
			if not [i,j] in win_loss_states:
				start_states.append([int(i),int(j)])
			
	for datum in data:
		if datum[2] == "item":
			if environment_matrix[datum[0]][0] != null:
				environment_matrix[[datum[0][0]-1,datum[0][1]]][2] = datum[1]
				
			if environment_matrix[datum[0]][1] != null:
				environment_matrix[[datum[0][0],datum[0][1]+1]][3] = datum[1]
				
			if environment_matrix[datum[0]][2] != null:
				environment_matrix[[datum[0][0]+1,datum[0][1]]][0] = datum[1]
				
			if environment_matrix[datum[0]][3] != null:
				environment_matrix[[datum[0][0],datum[0][1]-1]][1] = datum[1]
				
		elif datum[2] == "wall":
			if datum[1][0]:
				environment_matrix[datum[0]][1] = null
				environment_matrix[[datum[0][0],datum[0][1]+1]][3] = null
				
			if datum[1][1]:
				environment_matrix[datum[0]][2] = null
				environment_matrix[[datum[0][0]+1,datum[0][1]]][0] = null
	
	for x in range(numtrain):
		train()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if train:
		train()
		train = false
	else:
		if seconds > 0.2:
			if run():
				train = true
			seconds = 0
		seconds += delta

func train():
	# get starting place
	randomize()
	cur_pos = start_states[randi()%len(start_states)]
	# while goal state is not reached
	while not GameOver():
		# get all possible next states from cur_pos
		var possible_actions = getPossibleActions()
		# select any one action randomly
		var action = possible_actions[randi()%len(possible_actions)]
		# find the next state corresponding to the action selected
		var next_state = getNextState(action)
		# update the q_matrix
		q_matrix[cur_pos][action] = q_matrix[cur_pos][action] +\
			learning_rate * (environment_matrix[cur_pos][action] +\
			discount * max_arr(q_matrix[next_state]) - q_matrix[cur_pos][action])
		# go to the next state
		cur_pos = next_state
		
	count += 1
	get_parent().get_node("CanvasLayer/Panel/VBoxContainer/Label2").text = str(count)

func run():
	if starting:
		if String(agent_start) == "random":
			randomize()
			cur_pos = start_states[randi()%len(start_states)]
		else:
			cur_pos = agent_start
		starting = false
	
	position = Vector2(cur_pos[1]*64,cur_pos[0]*64)
	
	if not GameOver():
		var possible_actions = getPossibleActions()
		var action = possible_actions[0]
		
		for i in possible_actions:
			if q_matrix[cur_pos][i] > q_matrix[cur_pos][action]:
				action = i
		
		if q_matrix[cur_pos][action] == 0:
			action = possible_actions[randi()%len(possible_actions)]
		
		prev_pos.append(cur_pos)
		cur_pos = getNextState(action)
		
		return false
		
	else:
		prev_pos = []
		starting = true
		return true

func getPossibleActions():
	var result = []
	var i = 0
	for x in environment_matrix[cur_pos]:
		if x != null:
			result.append(i)
		i += 1
	return result
	
func getNextState(action):
	match(action):
		0:
			return [int(cur_pos[0]-1),int(cur_pos[1])]
		1:
			return [int(cur_pos[0]),int(cur_pos[1]+1)]
		2:
			return [int(cur_pos[0]+1),int(cur_pos[1])]
		3: 
			return [int(cur_pos[0]),int(cur_pos[1]-1)]
	
func GameOver():
	return cur_pos in win_loss_states or cur_pos in prev_pos

func max_arr(arr):
    var max_val = arr[0]

    for i in range(1, arr.size()):
        max_val = max(max_val, arr[i])

    return max_val