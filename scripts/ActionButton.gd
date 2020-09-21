extends Node2D

signal hold_completed


onready var _progress = $TextureProgress
onready var _ap = $AnimationPlayer


func start_hold():
	if !_ap.is_playing():
		_ap.play("hold")


func stop_hold():
	_ap.stop()
	_progress.value = 0


func _on_AnimationPlayer_animation_finished(_anim_name):
	emit_signal("hold_completed")

