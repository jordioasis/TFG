extends Timer

export var tiempo_restante: float = 30.0
onready var timer = $"."
onready var label = $"../CanvasLayer/Label"

func _ready() -> void:
	timer.wait_time = tiempo_restante
	timer.one_shot = true
	timer.start()

func _process(_delta: float) -> void:
	var tiempo_total_segundos = int(ceil(timer.time_left))
	var minutos = tiempo_total_segundos / 60
	var segundos = tiempo_total_segundos % 60
	
	label.text = "%02d:%02d" % [minutos, segundos]



func _on_Timer_timeout():
	set_process(false)
	label.text = "¡Tiempo terminado!"
