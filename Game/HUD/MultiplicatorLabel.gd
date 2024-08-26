extends Control


@export var FONT_COLORS := {
	2: Color("#f79ff9"),
	3: Color("#fd89c5"),
	4: Color("#fd85ae"),
	5: Color("#fec341"),
	6: Color("#f99831"),
	7: Color("#f15638"),
	8: Color("#f14938"),
}


@onready var label := $Label

func _ready():
	assert(label)
	set_value(0)


func set_value(p_value: int):
	
	if p_value < 2:
		label.text = ""
		scale = Vector2.ZERO
		return
	
	
	label.text = "x" + str(p_value)
	
	label.add_theme_color_override("font_color", FONT_COLORS.get(p_value, Color.WHITE))
	
	var tween := get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.1
		).from(Vector2.ZERO).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tween.finished


func _on_game_multiplicator_updated(multiplicator: Variant) -> void:
	set_value(multiplicator)
