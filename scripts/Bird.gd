extends Node2D


export var min_glide_time: float = 1.5
export var max_glide_time: float = 8.2

onready var _aplayer = $AnimatedSprite
onready var _timer = $Timer
onready var _rng = RandomNumberGenerator.new()


func _ready():
	_rng.randomize()
	
	_timer.start(_rng.randf_range(min_glide_time, max_glide_time))
	

func _on_Timer_timeout():
	_aplayer.play("fly")
	
	yield(_aplayer, "animation_finished")
	
	_aplayer.play("glide")
	_timer.start(_rng.randf_range(min_glide_time, max_glide_time))
