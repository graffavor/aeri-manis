extends PanelContainer


onready var _aplayer = $AnimationPlayer
onready var _label = $CenterContainer/VBoxContainer/Label


var _dead_text = """You were destroyed...
Better luck next time!"""

var _win_text = """You successfully traveled to next city!
Thanks for playing!
"""


func show_die_screen():
	_label.text = _dead_text
	visible = true
	_aplayer.play("show")


func show_end_screen():
	_label.text = _win_text
	visible = true
	_aplayer.play("show")


func _on_Button_pressed():
	# todo: switch scene
	pass

