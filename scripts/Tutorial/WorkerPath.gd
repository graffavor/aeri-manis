extends Path2D

signal cycle_complete


export(Curve2D) var default_path
export(Curve2D) var final_path

onready var _ap = $PathFollow2D/AnimationPlayer
onready var _worker = $PathFollow2D/Worker


func _ready():
	set_process(false)


func play_cycle(final: bool = false) -> void:
	set_process(true)
	curve = default_path
	
	yield(get_tree().create_timer(0.2), "timeout")
	
	_worker.hold_barrel()
	_worker.walk()
	
	_ap.play("move")
	
	yield(_ap, "animation_finished")
	
	# todo: stairs anim
	_worker.visible = false
	yield(get_tree().create_timer(1.5), "timeout")
	_worker.release_barrel()
	_worker.visible = true
	# ---
	
	if final:
		curve = final_path
	
	_worker.walk()
	
	_ap.play_backwards("move")
	
	yield(_ap, "animation_finished")
	
	_worker.idle()
	_worker.update_look_direction(Vector2.LEFT)
	
	emit_signal("cycle_complete")
	set_process(false)

