extends Modal


signal replay_pressed


const NEW_RECORD_TR := "NEW_RECORD"
const SCORE_TR := "SCORE"


@onready var in_game := get_node("%InGame")
@onready var in_game_best_score_label := get_node("%InGameBestScoreValue")

@onready var info := get_node("%Info")
@onready var info_rich_text_label := get_node("%RichTextLabel")

@onready var end_game := get_node("%EndGame")

@onready var score_label: Label = get_node("%ScoreLabel")
@onready var score_value_label: Label = get_node("%ScoreValue")
@onready var score_animation_player = get_node("%AnimationPlayer")

@onready var best_score_container := get_node("%BestScore")
@onready var best_score_label: Label = get_node("%BestScoreValue")


func _ready():
	super._ready()
	assert(in_game)
	assert(in_game_best_score_label)
	
	assert(info)
	assert(info_rich_text_label)
	assert(end_game)
	assert(score_label)
	assert(score_value_label)
	assert(score_animation_player)
	assert(best_score_container)
	assert(best_score_label)
	
	
	info_rich_text_label.text = tr(info_rich_text_label.text)
	
	_on_closed()


func open_in_game(best_score: int = 0):
	in_game_best_score_label.text = Utils.big_int_to_human_format(best_score)
	in_game.show()
	open()


func open_end_game(best_score: int, score: int):
	score_value_label.text = Utils.big_int_to_human_format(score)
	best_score_label.text = Utils.big_int_to_human_format(best_score)
	
	if best_score == score:
		best_score_container.hide()
		score_animation_player.play("best_score")
		score_label.text = NEW_RECORD_TR
		
	else:
		best_score_container.show()
		score_animation_player.play("RESET")
		score_label.text = SCORE_TR
	
	end_game.show()
	open()


func open_info():
	in_game.hide()
	info.show()
	open()


func _on_closed() -> void:
	if end_game.visible:
		replay_pressed.emit()
	
	in_game.hide()
	info.hide()
	end_game.hide()


func _on_replay_button_pressed():
	replay_pressed.emit()


func _on_info_button_pressed():
	open_info()
