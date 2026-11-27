extends Control

onready var selector_sospitos = $CenterContainer/PanelContainer/VBoxContainer/OptionSospitos
onready var selector_lloc = $CenterContainer/PanelContainer/VBoxContainer/OptionLloc

var llocs = ["Nord", "Sud", "Est", "Oest"]

func _ready():
	var sospitosos: Array = CaseManager.get_all_suspects()
	
	for i in range(sospitosos.size()):
		var sospitos: Dictionary = sospitosos[i]
		# Mostrem el nom visible a l'usuari (adapta la clau "nom" al teu JSON)
		selector_sospitos.add_item(sospitos.get("nom", "Desconegut"))
		# Guardem l'ID intern ("SOSP-03") ocult a cada opció
		selector_sospitos.set_item_metadata(i, sospitos.get("id", ""))
		
	selector_lloc.clear()
	for lloc in llocs:
		selector_lloc.add_item(lloc)

func _process(_delta):
	if Input.is_action_just_pressed("acusacio"):
		CaseManager.reanudar_temps()
		get_tree().paused = false
		get_parent().queue_free() 

func _on_BotoAcusar_pressed():
	# 1. Obtenim l'ID del sospitós i el lloc triats a la interfície
	# (Exemple assumint que guardes l'ID com a metadata o l'extraus de l'OptionButton)
	var index_sospitos = selector_sospitos.selected
	var sospitos_id_triat: String = selector_sospitos.get_item_metadata(index_sospitos)
	
	var index_lloc = selector_lloc.selected
	var lloc_triat: String = selector_lloc.get_item_text(index_lloc)
	
	# 2. Validem l'acusació directament amb el CaseManager (sense llegir fitxers de nou)
	var es_correcta: bool = CaseManager.comprovar_acusacio(sospitos_id_triat, lloc_triat)
	
	# 3. Canviem d'escena segons el resultat (OK o K.O.)
	if es_correcta:
		CaseManager.pausar_temps()
		get_tree().change_scene("res://levels/level/ResultatOK.tscn")
	else:
		CaseManager.pausar_temps()
		get_tree().change_scene("res://levels/level/ResultatKO.tscn")

func _on_BotoCancelar_pressed():
		CaseManager.reanudar_temps()
		get_tree().paused = false
		get_parent().queue_free() 
