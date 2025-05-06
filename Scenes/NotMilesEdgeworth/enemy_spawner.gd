extends Node2D
#class_name EnemySpawner
#@onready var main = get_node("/root/Battle_Scene")

var enemy_scene = preload("res://Scenes/NotMilesEdgeworth/enemy_battler.tscn")
var spawn_points := []

# Called when the node enters the scene tree for the first time.
func _ready():
	for spawnpoint in get_tree().get_nodes_in_group("SpawnPoints"):
		if spawnpoint is Marker2D:
			var enemy = enemy_scene.instantiate()
			add_child(enemy)
			enemy.position = spawnpoint.position

	
