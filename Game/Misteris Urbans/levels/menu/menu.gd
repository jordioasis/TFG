extends CanvasLayer

var level = preload ("res://levels/level/level.tscn")


func _ready() -> void:	
	pass


func _on_btnJugar_pressed():
	CaseManager.load_case_from_file("res://data/missions/missio_01.json")
	get_tree().change_scene("res://levels/level/level.tscn")


func _on_btnAleatoria_pressed():
	pass # Replace with function body.


func _on_btnSortir_pressed():
	get_tree().quit()
