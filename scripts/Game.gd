extends Node2D

export var round_time: float = 180.0


onready var _coml_slider = $CanvasLayer/FlyProgress/AnimationPlayer
onready var _bg = $Bg
onready var _ship = $Ship
onready var _ship_anim = $Ship/AnimationPlayer
onready var _end_screen = $CanvasLayer/EndScreen


func _ready():
	_ship.start_engines()
	_ship_anim.play("glide")
	_bg.material.set_shader_param("speed_scale", 0.025)
	
	_coml_slider.playback_speed = 1/round_time
	_coml_slider.play("slide")
	
	_ship.connect("dead", self, "_on_death")


func _on_AnimationPlayer_animation_finished(_anim_name):
	get_tree().paused = true
	_bg.material.set_shader_param("speed_scale", 0)
	_ship_anim.play("end")
	
	yield(_ship_anim, "animation_finished")
	
	_end_screen.show_end_screen()

func _on_death():
	get_tree().paused = true
	_end_screen.show_die_screen()

