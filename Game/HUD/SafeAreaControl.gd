extends Control


@export var enable_iOS := true
@export var enable_android := true



static func control_to_window_safe_area(control: Control):
	if control.get_viewport() != control.get_tree().root:
		return
	
	if not OS.get_name() == "iOS": #only for iOS, android use immersive mode
		return
	
	#print_debug("Window is full screen: ", Window.MODE_FULLSCREEN == control.get_window().mode)
	
	var window_to_root := Transform2D.IDENTITY.scaled(
		control.get_tree().root.size / control.get_window().size)
		
	var safe_area_root: Rect2 = window_to_root * Rect2(
		DisplayServer.get_display_safe_area())
	
	var parent_to_root = (control.get_viewport_transform() * 
		control.get_global_transform() * 
		control.get_transform().affine_inverse())
		
	var root_to_parent = parent_to_root.affine_inverse()
	
	#var viewport_relative_to_parent = root_to_parent * (
		#Rect2(Vector2.ZERO, control.get_viewport().size))
		
	var safe_area_relative_to_parent = root_to_parent * (safe_area_root)
	
	#print("Screen size: ", DisplayServer.screen_get_size())
	#print("Window size: ", control.get_window().size)
	#print("Root/Viewport size: ", control.get_tree().root.size) # <==> get_viewport()
	#print("Safe area size: ", Rect2(DisplayServer.get_display_safe_area()).size)
	
	control.set_deferred("position", safe_area_relative_to_parent.position)
	control.set_deferred("size", safe_area_relative_to_parent.size)


func _ready():
	get_tree().get_root().size_changed.connect(_on_window_resized)
	to_safe_area()


func is_enabled() -> bool:
	match OS.get_name():
		"Android":
			return enable_android
		"iOS":
			return enable_iOS
	
	return false


func to_safe_area():
	if not is_enabled():
		return
	
	control_to_window_safe_area(self)


func _on_window_resized():
	to_safe_area()
