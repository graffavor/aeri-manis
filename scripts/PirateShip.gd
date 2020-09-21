extends Node2D

signal dead


export(PackedScene) var ball_scene

export var max_health: int = 2
export var reload_time: float = 6.0
export var dodge_window: float = 1.0
export var muzzle_velocity: float = 350.0

export var collision_layer: int = 64

enum States {
	DEFAULT,
	READY,
	RELOADING,
	SHOOTING,
	DODGING,
	DEAD
}

onready var _sound = $AudioStreamPlayer2D
onready var _aplayer = $AnimationPlayer
onready var _muzzle_pos = $Pivot/MuzzlePos
onready var _timer = $Timer
onready var _particles = $Pivot/Particles2D

var _state = States.DEFAULT
var _cur_health : = max_health

var _ship: Node2D = null
onready var _rng = RandomNumberGenerator.new()

var _sounds = {
	"shoot": preload("res://assets/sounds/CannonShoot.wav"),
	"hit": preload("res://assets/sounds/Explosion4.wav")
}


func _ready():
	_rng.randomize()
	$Pivot/BottomProp.play("default")
	$Pivot/BackProp.play("default")
	
	_aplayer.play("appear")
	
	yield(_aplayer, "animation_finished")
	
	yield(get_tree().create_timer(_rng.randf_range(5.0, 8.0)), "timeout")
	
	_state = States.READY


func _process(_delta):
	match _state:
		States.READY:
			_shoot()
		_:
			return


func set_ship(ship: Node2D):
	_ship = ship


func _shoot():
	if _state != States.READY:
		return
	
	_state = States.SHOOTING
	
	var ball = ball_scene.instance()
	ball.collision_layer = collision_layer
	ball.collision_mask = collision_layer
	
	get_tree().get_root().add_child(ball)
	
	var vel = muzzle_velocity * _muzzle_pos.global_position.direction_to(_ship.global_position)
	
	ball.global_position = _muzzle_pos.global_position
	ball.linear_velocity = vel
	
	if !_sound.playing:
		_sound.stream = _sounds["shoot"]
		_sound.play()
	
	_state = States.RELOADING
	_timer.start(reload_time + _rng.randf_range(-1.0, 1.0))


func _dodge():
	pass


func _on_ShotDetector_body_entered(_body):
	pass # Replace with function body.


func _on_Timer_timeout():
	match _state:
		States.RELOADING:
			_state = States.READY


func _on_HitCollider_body_entered(body):
	if _cur_health <= 0:
		return
	
	_particles.position = body.global_position - $Pivot.global_position
	_particles.emitting = true
	
	body.queue_free()
	
	_cur_health -= 1
	
	if !_sound.playing:
		_sound.stream = _sounds["hit"]
		_sound.play()
	
	if _cur_health == 0:
		_state = States.DEAD
		_timer.stop()
		_aplayer.play("die")
		
		yield(_aplayer, "animation_finished")
		
		emit_signal("dead")
		
		queue_free()
