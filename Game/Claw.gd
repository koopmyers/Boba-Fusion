extends CharacterBody2D


signal armed
signal dropped

const SPEED := 700
const BUBBLE_DROP_IMPULSE := 800
const ARM_DURATION := 0.5 # sec


var loaded := false
var is_armed := false

var drop_position_x := 0.0 # global
var user_dropped := false

var next_bubble: TapiocaBubble
var current_bubble: TapiocaBubble

@onready var timer := $Timer
@onready var next_bubble_position: Vector2 = $Marker2D.position
@onready var collision_shape := $CollisionShape2D


func load_bubble(bubble):
	
	bubble.global_position.x = 0
	bubble.global_position.y = global_position.y + next_bubble_position.y
	
	next_bubble = bubble
	loaded = true
	
	await next_bubble.grow()
	if not is_armed:
		arm()


func unload():
	loaded = false
	is_armed = false
	
	user_dropped = false
	current_bubble = null
	next_bubble = null


func arm():
	if not loaded:
		return
	
	drop_position_x = 0.0
	position.x = 0.0
	
	var bubble = next_bubble
	
	loaded = false
	next_bubble = null
	
	var tween := get_tree().create_tween()
	tween.tween_property(bubble, "global_position", global_position, ARM_DURATION
		).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
	
	await tween.finished
	
	if not is_instance_valid(bubble): # bubble has been freed while tweening
		return
	
	is_armed = true
	current_bubble = bubble
	collision_shape.shape = current_bubble.get_collision_shape()
	armed.emit()


func _physics_process(delta):
	if not is_armed:
		return
		
	var target := Vector2(drop_position_x, global_position.y)
	
	if SPEED*0.1 < position.distance_squared_to(target):
		var movement := position.direction_to(target)* SPEED
		var collision := move_and_collide(movement * delta)
		
		if is_instance_valid(current_bubble):
			current_bubble.global_position = global_position
		
		if collision:
			drop()
	
	elif user_dropped:
		drop()


func _on_user_inputs_controller_bubble_dropped(pos_x: float) -> void:
	if not is_armed:
		return
	
	if user_dropped:
		return
	
	drop_position_x = pos_x
	user_dropped = true


func drop():
	if not is_armed:
		return
	
	if is_instance_valid(current_bubble):
		current_bubble.fall(BUBBLE_DROP_IMPULSE)
		current_bubble = null
	
	is_armed = false
	user_dropped = false
	drop_position_x = 0.0
	
	if not is_armed and loaded:
		arm()
	
	dropped.emit()
