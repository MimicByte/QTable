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
onready var player = self.get_node("Player")

var map = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	var file = File.new()
	file.open(player.fileName + ".txt", file.READ)
	
	map = get_node("Player").map
	
	for i in map["size"][0]:
		for j in map["size"][1]:
			Background.set_cell(j,i,Background.tile_set.find_tile_by_name("Floor"))
			
			if i == 0:
				UpWall.set_cell(j,i,UpWall.tile_set.find_tile_by_name("WallUp"))
			elif i == map["size"][0]-1:
				DownWall.set_cell(j,i,DownWall.tile_set.find_tile_by_name("WallDown"))
				
			if j == 0:
				LeftWall.set_cell(j,i,LeftWall.tile_set.find_tile_by_name("WallLeft"))
			elif j == map["size"][1]-1:
				RightWall.set_cell(j,i,RightWall.tile_set.find_tile_by_name("WallRight"))
				
	for datum in map["data"]:
		if datum[2] == "item":
			Items.set_cell(datum[0][1],datum[0][0],Items.tile_set.find_tile_by_name(datum[3]))
		elif datum[2] == "wall":
			if datum[1][0]:
				RightWall.set_cell(datum[0][1],datum[0][0],RightWall.tile_set.find_tile_by_name("WallRight"))
				LeftWall.set_cell(datum[0][1]+1,datum[0][0],LeftWall.tile_set.find_tile_by_name("WallLeft"))
			if datum[1][1]:
				DownWall.set_cell(datum[0][1],datum[0][0],DownWall.tile_set.find_tile_by_name("WallDown"))
				UpWall.set_cell(datum[0][1],datum[0][0]+1,UpWall.tile_set.find_tile_by_name("WallUp"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
