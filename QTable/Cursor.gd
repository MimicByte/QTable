extends Sprite

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(TileSet) var tileset : TileSet
onready var root = get_parent()
var playerTexture = preload("res://MLTiles.png")
var labelFont = preload("res://TestFont.tres")

var values = []

var currentTile = 0

var tiles = ["Diamond","Emerald","Coin","Fire","WallDown","WallRight","Player","WinLoss","EraserItems","EraserDownWall","EraserRightWall","EraserPlayer","EraserWinLoss","ValuePainter"]
var items = ["Diamond","Emerald","Coin","Fire"]

# Called when the node enters the scene tree for the first time.
func _ready():
	root.get_node("CanvasLayer/Panel2/SpinBox").connect("value_changed",self,"updateValue")
	
	# Set default cursor
	texture = tileset.tile_get_texture(tileset.find_tile_by_name(tiles[currentTile]))
	region_rect = tileset.tile_get_region(tileset.find_tile_by_name(tiles[currentTile]))
	if region_rect.has_no_area():
		region_enabled = false
	else:
		region_enabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Every frame set cursor position to mouse position
	position = (get_global_mouse_position()+Vector2(32,32)).snapped(Vector2(64,64))-Vector2(32,32)
	
func _unhandled_input(event):
	if event.is_action_pressed("ui_page_up"):
		currentTile += 1
		if currentTile == len(tiles):
			currentTile = 0
		updateTexture()
		
	elif event.is_action_pressed("ui_page_down"):
		currentTile -= 1
		if currentTile < 0:
			currentTile = len(tiles)-1
		updateTexture()
		
	elif event.is_action_pressed("click"):
		var pos = root.Background.world_to_map(get_global_mouse_position())
		
		# Check if click is within map bounds
		if pos.x >= 0 and pos.y >= 0 and pos.x < root.currentSize[1] and pos.y < root.currentSize[0]:
			# Check if current tile is the Player
			if tiles[currentTile] == "Player":
				root.Items.set_cellv(pos,-1)
				root.data.remove(root.points.find([pos.y,pos.x,"item"]))
				root.points.remove(root.points.find([pos.y,pos.x,"item"]))
				root.agent_start = [pos.y,pos.x]
				get_parent().get_node("Player").position = root.Background.map_to_world(pos)
				get_parent().get_node("Player").show()
			
			# Check if current tile is a win or loss state
			elif tiles[currentTile] == "WinLoss" and not [pos.y,pos.x] in root.win_loss_states:
				root.WinLossStates.set_cellv(pos,root.WinLossStates.tile_set.find_tile_by_name("WinLoss"))
				root.win_loss_states.append([pos.y,pos.x])
				print(root.win_loss_states)
			
			# Check if the current tile is the value painter
			elif tiles[currentTile] == "ValuePainter" and [pos.y,pos.x,"item"] in root.points:
				root.data[root.points.find([pos.y,pos.x,"item"])][1] = int(root.get_node("CanvasLayer/Panel2/SpinBox").value)
				updateTexture()
			
			#Check if the current tile is the eraser
			elif "Eraser" in tiles[currentTile]:
				erase(pos)
			
			# Check if the current tile is an item
			elif tiles[currentTile] in items:
				root.Items.set_cellv(pos,root.Items.tile_set.find_tile_by_name(tiles[currentTile]))
				
				# Check if tile already exists
				if [pos.y,pos.x,"item"] in root.points:
					root.data[root.points.find([pos.y,pos.x,"item"])][3] = tiles[currentTile]
				else:
					root.data.append([[pos.y,pos.x],0,"item",tiles[currentTile]])
					root.points.append([pos.y,pos.x,"item"])
			
			# Check if current tile is a right wall and click is not on the right edge of the map
			elif tiles[currentTile] == "WallRight" and pos.x < root.currentSize[1]-1:
				root.RightWall.set_cellv(pos,root.RightWall.tile_set.find_tile_by_name("WallRight"))
				root.LeftWall.set_cellv(pos+Vector2.RIGHT,root.LeftWall.tile_set.find_tile_by_name("WallLeft"))
				
				# Check if wall already exists in this tile
				if [pos.y,pos.x,"wall"] in root.points:
					root.data[root.points.find([pos.y,pos.x,"wall"])][1][0] = true
				else:
					root.data.append([[pos.y,pos.x],[true,false],"wall","wall"])
					root.points.append([pos.y,pos.x,"wall"])
			
			# Check if curent tile is a down wall and click is not on the bottom edge of the map
			elif tiles[currentTile] == "WallDown" and pos.y < root.currentSize[0]-1:
				root.DownWall.set_cellv(pos,root.DownWall.tile_set.find_tile_by_name("WallDown"))
				root.UpWall.set_cellv(pos+Vector2.DOWN,root.UpWall.tile_set.find_tile_by_name("WallUp"))
				
				# Check if wall already exists in this tile
				if [pos.y,pos.x,"wall"] in root.points:
					root.data[root.points.find([pos.y,pos.x,"wall"])][1][1] = true
				else:
					root.data.append([[pos.y,pos.x],[false,true],"wall","wall"])
					root.points.append([pos.y,pos.x,"wall"])
						
func updateTexture():
	# Clear all value labels
	for n in values:
		n.queue_free()
		
	# Set values to empty
	values = []
	root.get_node("CanvasLayer/Panel2").hide()
	get_node("Label").hide()
	
	#Enable Value Painter
	if tiles[currentTile] == "ValuePainter":
		root.get_node("CanvasLayer/Panel2").show()
		get_node("Label").show()
		texture = null
		
		for d in root.data:
			if d[2] == "item":
				var nodeLabel = Label.new()
				nodeLabel.margin_left = root.Background.map_to_world(Vector2(d[0][1],d[0][0])).x+12
				nodeLabel.margin_top = root.Background.map_to_world(Vector2(d[0][1],d[0][0])).y+17
				nodeLabel.margin_right = nodeLabel.margin_left+19+20
				nodeLabel.margin_bottom = nodeLabel.margin_top+14+15
				nodeLabel.align = Label.ALIGN_CENTER
				nodeLabel.valign = Label.VALIGN_CENTER
				nodeLabel.grow_horizontal = Control.GROW_DIRECTION_BOTH
				nodeLabel.text = str(d[1])
				nodeLabel.add_font_override("font",labelFont)
				nodeLabel.add_color_override("font_color",Color.black)
				nodeLabel.add_color_override("font_color_modulate",Color.white)
				nodeLabel.show()
				root.add_child(nodeLabel)
				values.append(nodeLabel)
				
	elif tiles[currentTile] == "Player":
		texture = playerTexture
		region_rect = Rect2(64,0,64,64)
		region_enabled = true
		
	elif "Eraser" in tiles[currentTile]:
		texture = load("res://" + tiles[currentTile] + ".png")
		region_enabled = false
		
	else:
		texture = tileset.tile_get_texture(tileset.find_tile_by_name(tiles[currentTile]))
		region_rect = tileset.tile_get_region(tileset.find_tile_by_name(tiles[currentTile]))
		
		if region_rect.has_no_area():
			region_enabled = false
		else:
			region_enabled = true
				
func updateValue(value):
	get_node("Label").text = str(int(value))
	
func erase(pos):
	# Check if erasing an item and if item exists under click
	if tiles[currentTile] == "EraserItems" and [pos.y,pos.x,"item"] in root.points:
		root.Items.set_cellv(pos,-1)
		root.data.remove(root.points.find([pos.y,pos.x,"item"]))
		root.points.remove(root.points.find([pos.y,pos.x,"item"]))
	
	# Check if erasing a downward wall and wall exists
	elif tiles[currentTile] == "EraserDownWall" and [pos.y,pos.x,"wall"] in root.points and root.data[root.points.find([pos.y,pos.x,"wall"])][1][1]:
		# Check if there is a right wall in the same tile
		if root.data[root.points.find([pos.y,pos.x,"wall"])][1][0]:
			root.data[root.points.find([pos.y,pos.x,"wall"])][1][1] = false
		else:
			root.data.remove(root.points.find([pos.y,pos.x,"wall"]))
			root.points.remove(root.points.find([pos.y,pos.x,"wall"]))
		
		root.DownWall.set_cellv(pos,-1)
		root.UpWall.set_cell(pos.x,pos.y+1,-1)
	
	# Check if erasing a rightward wall and wall exists
	elif tiles[currentTile] == "EraserRightWall" and [pos.y,pos.x,"wall"] in root.points and root.data[root.points.find([pos.y,pos.x,"wall"])][1][0]:
		# Check if there is a down wall in the same tile
		if root.data[root.points.find([pos.y,pos.x,"wall"])][1][1]:
			root.data[root.points.find([pos.y,pos.x,"wall"])][1][0] = false
		else:
			root.data.remove(root.points.find([pos.y,pos.x,"wall"]))
			root.points.remove(root.points.find([pos.y,pos.x,"wall"]))
		
		root.RightWall.set_cellv(pos,-1)
		root.LeftWall.set_cell(pos.x+1,pos.y,-1)
	
	# Check if erasing the player and player exists under click
	elif tiles[currentTile] == "EraserPlayer" and String(root.agent_start) != "random" and [pos.y,pos.x] == root.agent_start:
		root.agent_start = "random"
		get_parent().get_node("Player").hide()
	
	# Check if erasing a win or loss and win or loss exists under click
	elif tiles[currentTile] == "EraserWinLoss" and [pos.y,pos.x] in root.win_loss_states:
		root.WinLossStates.set_cellv(pos,-1)
		root.win_loss_states.remove(root.win_loss_states.find([pos.y,pos.x]))