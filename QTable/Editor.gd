extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var Background = self.get_node("Background")
onready var Items = self.get_node("Items")
onready var UpWall = self.get_node("UpWall")
onready var DownWall = self.get_node("DownWall")
onready var LeftWall = self.get_node("LeftWall")
onready var RightWall = self.get_node("RightWall")
onready var WinLossStates = self.get_node("WinLossStates")
onready var SizeLabel = self.get_node("CanvasLayer/Panel/VBoxContainer/SizeLabel")

var map = {}
var data = []
var points = []
var agent_start = "random"
var win_loss_states = []

var currentSize = [6,6]

# Called when the node enters the scene tree for the first time.
func _ready():
	
	get_node("CanvasLayer/Panel/VBoxContainer/save/FileDialog").connect("file_selected",self,"saveMap")
	get_node("CanvasLayer/Panel/VBoxContainer/load/FileDialog").connect("file_selected",self,"loadMap")
	
	for i in currentSize[0]:
		for j in currentSize[1]:
			Background.set_cell(j,i,Background.tile_set.find_tile_by_name("Floor"))
			
			if i == 0:
				UpWall.set_cell(j,i,UpWall.tile_set.find_tile_by_name("WallUp"))
			elif i == currentSize[0]-1:
				DownWall.set_cell(j,i,DownWall.tile_set.find_tile_by_name("WallDown"))
				
			if j == 0:
				LeftWall.set_cell(j,i,LeftWall.tile_set.find_tile_by_name("WallLeft"))
			elif j == currentSize[1]-1:
				RightWall.set_cell(j,i,RightWall.tile_set.find_tile_by_name("WallRight"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if len(data) != len(points):
		print(data,"\n",points,"\n")

func setSize(size):
	# Clear map
	for i in currentSize[0]:
		for j in currentSize[1]:
			Background.set_cell(j,i,-1)
			
			if i == 0:
				UpWall.set_cell(j,i,-1)
				
			if i == currentSize[0]-1:
				DownWall.set_cell(j,i,-1)
				
			if j == 0:
				LeftWall.set_cell(j,i,-1)
				
			if j == currentSize[1]-1:
				RightWall.set_cell(j,i,-1)
				
	# Set new size
	currentSize = size
	
	# Redraw map
	for i in currentSize[0]:
		for j in currentSize[1]:
			Background.set_cell(j,i,Background.tile_set.find_tile_by_name("Floor"))
			
			if i == 0:
				UpWall.set_cell(j,i,UpWall.tile_set.find_tile_by_name("WallUp"))
				
			if i == currentSize[0]-1:
				DownWall.set_cell(j,i,DownWall.tile_set.find_tile_by_name("WallDown"))
				
			if j == 0:
				LeftWall.set_cell(j,i,LeftWall.tile_set.find_tile_by_name("WallLeft"))
				
			if j == currentSize[1]-1:
				RightWall.set_cell(j,i,RightWall.tile_set.find_tile_by_name("WallRight"))
				
	# Update UI
	SizeLabel.text = "Size: " + str(currentSize[0]) + "," + str(currentSize[1])
	
	# Keep items and walls that are within the new size
	var datatemp = []
	var pointstemp = []
	for p in data:
		if p[0][0] < currentSize[0] and p[0][1] < currentSize[1] and p[2] == "item":
			datatemp.append(p)
			pointstemp.append([p[0][0],p[0][1],p[3]])
		elif p[0][0] < currentSize[0] and p[0][1] < currentSize[1] and p[2] == "wall":
			var wallFlag = [false,false]
			if p[1][0] and p[0][1] < currentSize[1]-1:
				wallFlag[0] = true
			else:
				LeftWall.set_cell(p[0][1]+1,p[0][0],-1)
			if p[1][1] and p[0][0] < currentSize[0]-1:
				wallFlag[1] = true
			else:
				UpWall.set_cell(p[0][1],p[0][0]+1,-1)
			if wallFlag[0] or wallFlag[1]:
				datatemp.append([p[0],wallFlag,p[2],p[3]])
				pointstemp.append([p[0][0],p[0][1],p[3]])
		else:
			if p[2] == "item":
				Items.set_cell(p[0][1],p[0][0],-1)
			elif p[2] == "wall":
				if p[1][0]:
					RightWall.set_cell(p[0][1],p[0][0],-1)
					LeftWall.set_cell(p[0][1]+1,p[0][0],-1)
				if p[1][1]:
					DownWall.set_cell(p[0][1],p[0][0],-1)
					UpWall.set_cell(p[0][1],p[0][0]+1,-1)
	data = datatemp
	points = pointstemp
	
	# Make sure the agent is within the map
	if str(agent_start) != "random" and ( agent_start[0] >= currentSize[0] or agent_start[1] >= currentSize[1]):
		get_node("Player").hide()
		agent_start = "random"
		
	# Make sure win and loss states are within the map
	var wltemp = []
	for wl in win_loss_states:
		if wl[0] < currentSize[0] and wl[1] < currentSize[1]:
			wltemp.append(wl)
		else:
			WinLossStates.set_cell(wl[1],wl[0],-1)
	win_loss_states = wltemp
	
	# Update the cursor
	get_node("Cursor").updateTexture()
	

func _unhandled_input(event):
	if event.is_action_pressed("ui_down"):
		setSize([currentSize[0]+1,currentSize[1]])
	elif event.is_action_pressed("ui_up"):
		if currentSize[0] != 1:
			setSize([currentSize[0]-1,currentSize[1]])
	elif event.is_action_pressed("ui_right"):
		setSize([currentSize[0],currentSize[1]+1])
	elif event.is_action_pressed("ui_left"):
		if currentSize[1] != 1:
			setSize([currentSize[0],currentSize[1]-1])
			
func saveMap(path):
	map = {
		"size" : currentSize,
		"win_loss_states" : win_loss_states,
		"discount" : get_node("CanvasLayer/Panel/VBoxContainer/Discount").value,
		"learning_rate" : get_node("CanvasLayer/Panel/VBoxContainer/LearningRate").value,
		"numtrain" : get_node("CanvasLayer/Panel/VBoxContainer/NumTrain").value,
		"agent_start" : agent_start,
		"data" : data
		}
	var save = File.new()
	save.open(path,File.WRITE)
	save.store_line(to_json(map))
	save.close()

func loadMap(path):
	var file = File.new()
	file.open(path, file.READ)
	
	map = JSON.parse(file.get_as_text()).result
	
	# Clear the map items and walls
	for p in data:
		if p[2] == "item":
			Items.set_cell(p[0][1],p[0][0],-1)
		elif p[2] == "wall":
			if p[1][0]:
				RightWall.set_cell(p[0][1],p[0][0],-1)
				LeftWall.set_cell(p[0][1]+1,p[0][0],-1)
			if p[1][1]:
				DownWall.set_cell(p[0][1],p[0][0],-1)
				UpWall.set_cell(p[0][1],p[0][0]+1,-1)
	
	# Set the size of the map
	setSize(map["size"])
	# Repopulate data and points and draw items
	data = []
	points = []
	for datum in map["data"]:
		data.append(datum)
		
		points.append([datum[0][0],datum[0][1],datum[2]])
		
		if datum[2] == "item":
			Items.set_cell(datum[0][1],datum[0][0],Items.tile_set.find_tile_by_name(datum[3]))
		elif datum[2] == "wall":
			if datum[1][0]:
				RightWall.set_cell(datum[0][1],datum[0][0],RightWall.tile_set.find_tile_by_name("WallRight"))
				LeftWall.set_cell(datum[0][1]+1,datum[0][0],LeftWall.tile_set.find_tile_by_name("WallLeft"))
			if datum[1][1]:
				DownWall.set_cell(datum[0][1],datum[0][0],DownWall.tile_set.find_tile_by_name("WallDown"))
				UpWall.set_cell(datum[0][1],datum[0][0]+1,UpWall.tile_set.find_tile_by_name("WallUp"))
		
	# Set player position if not random or hide player if is random
	agent_start = map["agent_start"]
	if str(agent_start) != "random":
		get_node("Player").position = Background.map_to_world(Vector2(agent_start[1],agent_start[0]))
		get_node("Player").show()
	else:
		get_node("Player").hide()
		
	# Update UI
	get_node("CanvasLayer/Panel/VBoxContainer/Discount").value = map["discount"]
	get_node("CanvasLayer/Panel/VBoxContainer/LearningRate").value = map["learning_rate"]
	get_node("CanvasLayer/Panel/VBoxContainer/NumTrain").value = map["numtrain"]
	
	# Clear win and loss states
	for p in win_loss_states:
		WinLossStates.set_cell(p[1],p[0],-1)
		
	# Repopulate win and loss states
	win_loss_states = []
	for state in map["win_loss_states"]:
		win_loss_states.append(state)
	for p in win_loss_states:
		WinLossStates.set_cell(p[1],p[0],WinLossStates.tile_set.find_tile_by_name("WinLoss"))
	
	# Update Cursor
	get_node("Cursor").updateTexture()
				