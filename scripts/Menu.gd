extends Control


func _ready():
	$VBoxContainer/NewGame.grab_focus()


func _on_NewGame_pressed():
	get_tree().change_scene("res://scenes/StartCutscene.tscn")


func _on_Credits_pressed():
	get_tree().change_scene("res://scenes/Credits.tscn")


func _on_Exit_pressed():
	get_tree().quit()
