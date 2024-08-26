extends Button


@export var bus_name: String = "Master"
@onready var bus_index := AudioServer.get_bus_index(bus_name)


func _ready():
	toggled.connect(_on_toggled)


func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		AudioServer.set_bus_volume_db(bus_index, -80)
	else:
		AudioServer.set_bus_volume_db(bus_index, 0)
