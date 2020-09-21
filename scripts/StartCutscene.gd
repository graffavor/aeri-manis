extends Node2D


onready var _fp = $FinalPlayer
onready var _ship = $City/Ship
onready var _worker = $City/WorkerPath
onready var _trap = $City/Trap
onready var _capt_nav_player = $City/YSort/Characters/CaptainToShip/PathFollow2D/AnimationPlayer
onready var _capt = $City/YSort/Characters/CaptainToShip/PathFollow2D/Captain
onready var _dialog_ui = $UI/DialogUI

enum States {
	START,
	FIRST_DIALOG_COMPLETE,
	WORKER_COMPLETE,
	SECOND_DIALOG_COMPLETE,
	CAPTAIN_WALK_COMPLETE
}

var _state = States.START

var _icons = {
	"trader": preload("res://resources/trader_icon.tres"),
	"worker": preload("res://resources/worker_icon.tres"),
	"captain": preload("res://resources/captain_icon.tres")
}


var _dialogs : = {
	"trader_start": [
		{"text": "Captain. One last thing while they finish loading your ship", "icon": _icons["trader"]},
		{"text": "Lately our sailort talking about increased amount of pirate attacks"},
		{"text": "So be careful. Dont forget to repair your ship and check cannons"}
	],
	"worker_finish": [
		{"text": "Ship loaded madam.", "icon": _icons["worker"]},
		{"text": "Good", "icon": _icons["trader"]},
		{"text": "So you good to go captain. Good luck!"}
	]
}


func _ready():
	_fp.play("start")
	
	yield(_fp, "animation_finished")
	
	_start_cutscene()


func _start_cutscene():
	_run_worker_cycle()
	
	_dialog_ui.play_dialog(_dialogs["trader_start"])
	
	yield(_dialog_ui, "dialog_completed")
	
	match _state:
		States.START:
			_dialog_ui.visible = false
			_state = States.FIRST_DIALOG_COMPLETE
		States.WORKER_COMPLETE:
			_play_second_dialog()


func _run_worker_cycle():
	_worker.play_cycle()
	
	yield(_worker, "cycle_complete")
	
	_worker.play_cycle(true)
	
	yield(_worker, "cycle_complete")
	
	match _state:
		States.START:
			_state = States.WORKER_COMPLETE
		States.FIRST_DIALOG_COMPLETE:
			_play_second_dialog()


func _play_second_dialog():
	_dialog_ui.play_dialog(_dialogs["worker_finish"])
	
	yield(_dialog_ui, "dialog_completed")
	
	_state = States.SECOND_DIALOG_COMPLETE
	
	_move_captain()
	_hide_dialog()


func _hide_dialog():
	yield(get_tree().create_timer(1.0), "timeout")
	_dialog_ui.visible = false


func _move_captain():
	_capt.play_anim("walk")
	_capt_nav_player.play("to_ship")
	
	yield(_capt_nav_player, "animation_finished")
	
	_state = States.CAPTAIN_WALK_COMPLETE
	_capt.play_anim("idle")
	var gpos = _capt.global_position
	
	_capt.get_parent().remove_child(_capt)
	
	_ship.add_child(_capt)
	_capt.global_position = gpos
	
	# todo: trap animation
	_trap.visible = false
	
	_ship.start_engines()
	_fp.play("final")
	
	yield(_fp, "animation_finished")
	
	get_tree().change_scene("res://scenes/Game.tscn")

