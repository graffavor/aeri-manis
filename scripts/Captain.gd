extends KinematicBody2D


export var is_player_controlled: bool = true
export var speed: float = 500.0


onready var _asprite = $AnimatedSprite


var _velocity: Vector2
var _attached_cannon: Node2D = null


func _unhandled_input(_event):
	if !is_player_controlled:
		return


func _ready():
	_asprite.play("idle")


func _process(delta):
	if !is_player_controlled:
		return
	
	_velocity = Vector2.ZERO
	
	_velocity.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	_velocity.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	
	if _velocity != Vector2.ZERO:
		if _asprite.animation != "walk":
			_asprite.play("walk")
		
		_asprite.flip_h = _velocity.x > 0
	elif _asprite.animation != "idle":
		_asprite.play("idle")
	
	move_and_slide(_velocity.normalized() * speed * 20 * delta)


func play_anim(name: String) -> void:
	_asprite.play(name)


func use_cannon(cannon: Node2D) -> void:
	_attached_cannon = cannon
	
	if cannon:
		_asprite.flip_h = cannon.position.x > position.x
		
		_asprite.play("hold")
		is_player_controlled = false
	else:
		is_player_controlled = true
		_asprite.play("idle")

