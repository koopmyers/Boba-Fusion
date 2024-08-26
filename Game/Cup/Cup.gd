extends StaticBody2D


signal overflowed


var tint: Tint:
	set(x):
		tint = x
		if is_inside_tree():
			water.surface_color = tint.water_surface_color
			water.color = tint.water_color


var is_in_danger := false:
	set(x):
		is_in_danger = x
		#print_debug("Is in danger: ", is_in_danger)
		
		if is_in_danger:
			if not animation_player.is_playing():
				animation_player.play("in_limit")
		
		elif animation_player.is_playing():
			animation_player.play("RESET")
			


var body_in_limit_area := 0
var is_overflowed := false

@onready var animation_player := $AnimationPlayer
@onready var water := $WaterClip/Water


func reset():
	is_overflowed = false
	is_in_danger = false
	water.reset_level()
	animation_player.play("RESET")


func _on_limit_area_2d_body_entered(body: Node2D) -> void:
	if not body is TapiocaBubble:
		return
	
	body_in_limit_area += 1
	if body.invincible:
		return
	
	body.in_danger = true
	if not (is_overflowed or is_in_danger):
		is_in_danger = true


func _on_limit_area_2d_body_exited(body: Node2D) -> void:
	if not body is TapiocaBubble:
		return
	
	body_in_limit_area -= 1
	#if body.invincible:
		#return
	
	body.in_danger = false
	if not is_overflowed and body_in_limit_area <= 0:
		is_in_danger = false


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if "in_limit" != anim_name:
		return
	
	is_overflowed = true
	overflowed.emit()
