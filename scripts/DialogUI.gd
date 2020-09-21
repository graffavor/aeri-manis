extends Control

signal segment_completed(segment_idx)
signal dialog_completed


onready var _icon_rect = $NinePatchRect/HSplitContainer/CenterContainer/TextureRect
onready var _text_label = $NinePatchRect/HSplitContainer/MarginContainer/Label

onready var _skip_container = $NinePatchRect/HBoxContainer


var _cur_segment_idx: int = -1
var _cur_dialog: Array


func play_dialog(dialog: Array) -> void:
	if !visible:
		visible = true
	
	$Tween.stop_all()
	
	_cur_dialog = dialog
	_cur_segment_idx = -1
	_next_phrase()


func _next_phrase() -> void:
	_cur_segment_idx += 1
	
	if _cur_segment_idx >= len(_cur_dialog):
		emit_signal("dialog_completed")
		return
	
	if "icon" in _cur_dialog[_cur_segment_idx]:
		_icon_rect.texture = _cur_dialog[_cur_segment_idx]["icon"]
	
	var text_len = len(_cur_dialog[_cur_segment_idx]["text"])
	$Tween.interpolate_method(
		self, "_show_char", 
		1, text_len,
		(text_len / 10) * 0.7
	)
	$Tween.start()
	
	_text_label.text = _cur_dialog[_cur_segment_idx]["text"][0]
	
	yield($Tween, "tween_all_completed")
	
	emit_signal("segment_completed", _cur_segment_idx)


func _show_char(n: int) -> void:
	_text_label.text = _cur_dialog[_cur_segment_idx]["text"].substr(0, n)


func _on_SkipButton_pressed():	
	if $Tween.is_active():
		$Tween.stop_all()
		
		_text_label.text = _cur_dialog[_cur_segment_idx]["text"]
	else:
		_next_phrase()
