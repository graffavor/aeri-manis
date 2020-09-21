extends Node2D

signal fix_completed(object)


onready var _fix_icon = $AnimatedSprite
onready var _abutton = $ActionButton

var _body_in_proximity: Node2D = null


func _unhandled_input(event):
	if !_body_in_proximity || !visible:
		return
	
	if event.is_action_pressed("interact"):
		if _abutton.visible:
			if event.pressed:
				_body_in_proximity.use_cannon(self)
				_abutton.start_hold()
			else:
				_abutton.stop_hold()
		else:  # detach
			_body_in_proximity.use_cannon(null)


func _ready():
	_fix_icon.play("default")


func show():
	visible = true
	_fix_icon.visible = true
	_fix_icon.play("default")


func _on_Area2D_body_entered(body):
	if !visible:
		return
	
	_body_in_proximity = body
	_abutton.visible = true


func _on_Area2D_body_exited(_body):
	if !visible:
		return
	
	_body_in_proximity = null
	_abutton.visible = false


func _on_ActionButton_hold_completed():
	_abutton.stop_hold()
	_abutton.visible = false
	emit_signal("fix_completed", self)
	
	if _body_in_proximity:
		_body_in_proximity.use_cannon(null)
		visible = false
		_fix_icon.visible = false
		_fix_icon.stop()

