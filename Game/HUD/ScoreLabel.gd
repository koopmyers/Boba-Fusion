extends Control


@onready var label := $Label


var color: Color:
	set(x):
		color = x
		label.add_theme_color_override("font_color", color)


func _ready():
	assert(label)
	label.text = "0"


func _on_game_score_updated(score: int, p_color := Color.WHITE) -> void:
	
	label.text = Utils.big_int_to_human_format(score)
	
	var tween := get_tree().create_tween()
	tween.tween_property(self, "color", p_color, 0.1)
	
	tween.parallel().tween_property(self, "scale", Vector2.ONE*1.25, 0.05
		).set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(self, "scale", Vector2.ONE, 0.05
		).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
