extends Node2D


export(PackedScene) var ball_scene

export var flipped: bool = false
export var muzzle_velocity: float = 350.0
export var reload_time: float = 2.0

onready var _abutton = $ActionButton
onready var _ball_spawn = $BallSpawn
onready var _trajectory_line = $Line2D
onready var _snd = $AudioStreamPlayer2D
onready var _reload_icon = $ReloadIcon
onready var _reload_ap = $ReloadIcon/AnimationPlayer

var _sounds = {
	"shoot": preload("res://assets/sounds/CannonShoot.wav"),
	"reload": preload("res://assets/sounds/CannonReload.wav")
}

var _body_in_proximity: Node2D = null
var _draw_trajectory: = false
var _angle_constraint : = [3.14, 2.42]

var _reloading : = false
var _can_shoot : = false


func _unhandled_input(event):
	if !_body_in_proximity:
		return
	
	if event.is_action_pressed("shoot") && !_reloading && _can_shoot:
		_shoot()
	
	if event.is_action_pressed("interact"):
		if _abutton.visible:
			if event.pressed:
				_abutton.start_hold()
			else:
				_abutton.stop_hold()
		else:  # detach
			_trajectory_line.clear_points()
			_draw_trajectory = false
			_body_in_proximity.use_cannon(null)


func _ready():
	if flipped:
		$Sprite.flip_h = true
		_ball_spawn.position.x *= -1
		_angle_constraint = [0.68, 0]


func _process(delta):
	if !_draw_trajectory:
		return
	
	_update_trajectory(delta)


func _update_trajectory(delta: float) -> void:
	_trajectory_line.clear_points()
	
	var mpos = get_global_mouse_position()
	var pos = _ball_spawn.global_position
	var angle = pos.angle_to_point(mpos)
	
	if !(abs(angle) <= _angle_constraint[0] && abs(angle) > _angle_constraint[1]):
		_can_shoot = false
		return
	
	_can_shoot = true
	
	var vel = muzzle_velocity * pos.direction_to(mpos)
	
	for _i in range(150):
		_trajectory_line.add_point(pos - global_position)
		
		vel.y += 49 * delta * 1.5
		pos += vel * delta


func _shoot():
	var ball = ball_scene.instance()
	get_tree().get_root().add_child(ball)
	
	var mpos = get_global_mouse_position()
	var pos = _ball_spawn.global_position
	
	var vel = muzzle_velocity * pos.direction_to(mpos)
	
	ball.global_position = pos
	ball.linear_velocity = vel
	
	_snd.stream = _sounds["shoot"]
	_snd.play()
	
	_reload()


func _reload():
	_reloading = true
	_reload_icon.visible = true
	_reload_ap.playback_speed = 1 / reload_time
	_reload_ap.play("reloading")


func _on_Area2D_body_entered(body):
	_body_in_proximity = body
	_abutton.visible = true


func _on_Area2D_body_exited(_body):
	_body_in_proximity = null
	_abutton.visible = false


func _on_ActionButton_hold_completed():
	_abutton.stop_hold()
	_abutton.visible = false
	if _body_in_proximity:
		_draw_trajectory = true
		_body_in_proximity.use_cannon(self)


func _on_AnimationPlayer_animation_finished(_anim_name):
	_snd.stream = _sounds["reload"]
	_snd.play()
	_reloading = false
	_reload_icon.visible = false
