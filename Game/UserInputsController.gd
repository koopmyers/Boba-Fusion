extends Node2D


signal bubble_dropped(pos_x: float)


func _unhandled_input(event):
	
	event = make_input_local(event)
	
	if event is InputEventScreenTouch:
		
		if event.is_pressed():
			bubble_dropped.emit(event.position.x)
	
	if OS.is_debug_build() and event.is_action_pressed("ui_accept"):
		bubble_dropped.emit(get_local_mouse_position().x)
