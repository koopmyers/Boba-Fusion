extends MarginContainer
class_name Modal


signal closed
signal opened


const OPEN_ANIMATION_TIME = 0.3
const CLOSE_ANIMATION_TIME = 0.2
const TRANSPARENT_MODULATE = Color(1, 1, 1, 0)
const OPAQUE_MODULATE = Color(1, 1, 1, 1)


@export var background: Control

var _open := false
var tween: Tween


func _ready():
	assert(background)
	background.gui_input.connect(_on_background_gui_input)
	
	hide()
	modulate = TRANSPARENT_MODULATE


func _on_background_gui_input(event):
	if event is InputEventMouse and event.is_pressed():
		close()


func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		close()


func open():
	if _open:
		return
	
	_open = true
	opened.emit()
	
	tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", OPAQUE_MODULATE, OPEN_ANIMATION_TIME
		).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	
	show()
	
	await tween.finished


func close():
	if not _open:
		return
	
	_open = false
	
	tween.kill()
	tween = create_tween()
	tween.tween_property(self, "modulate", TRANSPARENT_MODULATE, CLOSE_ANIMATION_TIME
		).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	
	await tween.finished
	hide()
	closed.emit()
