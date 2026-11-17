extends Control



func _on_btnJugar_pressed():
	get_tree().change_scene("res://levels/level_1/level_1.tscn")


func _on_btnAleatoria_pressed():
	pass # Replace with function body.


func _on_btnSortir_pressed():
	get_tree().quit()
