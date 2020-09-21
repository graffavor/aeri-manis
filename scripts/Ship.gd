extends Node2D

signal dead
signal health_changed(new_value, old_value)

export var max_health: int = 6
export var spawn_captain: bool = true
export(PackedScene) var captains_scn


onready var _capt_spawn_pos = $SpawnPosition
onready var _prop = $Back/Propeller
onready var _hit_sound = $HitAudioPlayer
onready var _hit_marks = $HitMarks
onready var _rng = RandomNumberGenerator.new()

var _cur_health : = max_health


func _ready():
	_rng.randomize()
	set_process(false)
	
	if spawn_captain and captains_scn != null:
		var capt = captains_scn.instance()
		_capt_spawn_pos.add_child(capt)
	
	for mark in _hit_marks.get_children():
		mark.connect("fix_completed", self, "_repair")


func start_engines():
	_prop.play("spin")


func stop_engines():
	_prop.play("default")


func get_health() -> int:
	return _cur_health


func _repair(_mark: Node2D):
	_cur_health += 1
	emit_signal("health_changed", _cur_health, _cur_health - 1)


func _on_HitCollider_body_entered(body):
	_hit_sound.play()
	body.queue_free()
	
	_cur_health -= 1
	emit_signal("health_changed", _cur_health, _cur_health + 1)
	
	if _cur_health <= 0:
		get_tree().paused = true
		$AnimationPlayer.playback_speed = 1.0
		$AnimationPlayer.play("die")
		
		yield($AnimationPlayer, "animation_finished")
		
		emit_signal("dead")
		
		return
	
	var pos_marks = _get_hit_marks()
	var rand_mark = pos_marks[_rng.randi_range(0, len(pos_marks) - 1)]
	
	rand_mark.show()


func _get_hit_marks() -> Array:
	var res = []
	
	for mark in _hit_marks.get_children():
		if !mark.visible:
			res.append(mark)
	
	return res
	
