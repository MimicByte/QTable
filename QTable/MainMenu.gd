extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("Panel/VBoxContainer/Play/FileDialog").connect("file_selected",self,"play")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func play(path):
	Global.fileName = path
	get_tree().change_scene("res://Main.tscn")