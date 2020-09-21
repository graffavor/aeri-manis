extends MarginContainer


export(NodePath) var ship

onready var _ship = get_node(ship)

onready var _hpcontainer = $VBoxContainer/MarginContainer/HBoxContainer
onready var _hpunit = $VBoxContainer/MarginContainer/HBoxContainer/HpUnit


func _ready():
	_ship.connect("health_changed", self, "_on_health_changed")
	
	while _hpcontainer.get_child_count() < _ship.get_health():
		_hpcontainer.add_child(_hpunit.duplicate())


func _on_health_changed(newv, _oldv):
	var diff = newv - _hpcontainer.get_child_count()
	
	if diff < 0:
		while _hpcontainer.get_child_count() > newv:
			_hpcontainer.remove_child(_hpcontainer.get_child(0))
	else:
		while _hpcontainer.get_child_count() < newv:
			_hpcontainer.add_child(_hpunit.duplicate())

