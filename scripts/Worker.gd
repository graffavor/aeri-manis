extends Node2D


onready var _up = $Upper
onready var _low = $Lower
onready var _ap = $AnimationPlayer

var _holding_barrel = false

var _check_look_direction = false
onready var _prev_pos: Vector2 = global_position


func _ready():
	idle()


func _process(_delta):
	if not _check_look_direction:
		return
	
	if _prev_pos != global_position:
		var look_direction = Vector2.LEFT
		
		if global_position.x > _prev_pos.x:
			look_direction = Vector2.RIGHT
		
		update_look_direction(look_direction)
		
		_prev_pos = global_position


func update_look_direction(dir: Vector2):
	_up.flip_h = dir == Vector2.RIGHT
	_low.flip_h = _up.flip_h


func idle():
	_check_look_direction = false
	if !_holding_barrel:
		$Upper.frame = 3
		_ap.play("idle")
	else:
		_ap.stop()
		$Upper.frame = 5


func walk():
	_check_look_direction = true
	_ap.play("walk")


func hold_barrel():
	_holding_barrel = true
	idle()


func release_barrel():
	_holding_barrel = false
	idle()

