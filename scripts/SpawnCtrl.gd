extends Node2D

signal pirate_appeared(pirate, direction)


export(PackedScene) var pirate_ship
export(NodePath) var player_ship

export var max_pirates: int = 2
export var attack_on_both_sides: bool = false
export var initial_timeout: float = 15.0
export var min_encounter_timeout: float = 20.0
export var max_encounter_timeout: float = 40.0


onready var _timer = $Timer
onready var _lpos = $AttackPosLeft
onready var _rpos = $AttackPosRight
onready var _rng = RandomNumberGenerator.new()

var _enabled = true


func _ready():
	_rng.randomize()
	_timer.start(initial_timeout)


func disable():
	_enabled = false
	_timer.stop()


func _on_Timer_timeout():
	if _enabled:
		_check_spawn_ship()


func _check_spawn_ship():
	var spots = _get_spots()
	
	if not len(spots["free"]) || len(spots["occ"]) >= max_pirates:
		_timer.start(_rng.randf_range(min_encounter_timeout, max_encounter_timeout))
		return
	
	for _i in range(_rng.randi_range(1, max_pirates - len(spots["occ"]))):
		# todo: a lot of extra spawn logic
		var spot = spots["free"][_rng.randi_range(0, len(spots["free"]) - 1)]
		
		var pirate = pirate_ship.instance()
		pirate.set_ship(get_node(player_ship))
		var dir = Vector2.RIGHT
		if spot.global_position.x < 740:
			dir = Vector2.LEFT
			pirate.scale.x = -1
		
		spot.add_child(pirate)
		
		emit_signal("pirate_appeared", pirate, dir)
		_timer.start(_rng.randf_range(min_encounter_timeout, max_encounter_timeout))


func _get_spots() -> Dictionary:
	var res = {
		"free": [],
		"occ": []
	}
	
	for child in _lpos.get_children():
		if child.get_child_count() == 0:
			res["free"].append(child)
		else:
			res["occ"].append(child)
	
	for child in _rpos.get_children():
		if child.get_child_count() == 0:
			res["free"].append(child)
		else:
			res["occ"].append(child)
	
	return res

