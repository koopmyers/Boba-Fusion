extends Node


const STORAGE_PATH := "user://store.ini"

const save_section := "save"
const best_score_key := "best_score"


var best_score: int = 0
var config_file := ConfigFile.new()

@onready var start_menu
@onready var game := $Game
@onready var menu := $Menus/Menu



func _ready():
	best_score = load_best_score()
	game.start()


func load_best_score() -> int:
	if  config_file.load(STORAGE_PATH) != OK: # If the file didn't load, ignore it.
		print("Coundn't load {file}".format({"file": STORAGE_PATH}))
		return 0
	
	return config_file.get_value(save_section, best_score_key, 0)


func save_best_score(p_best_score: int):
	config_file.set_value(save_section, best_score_key, p_best_score)
	
	if  config_file.save(STORAGE_PATH) != OK:
		print("Coundn't save {file}".format({"file": STORAGE_PATH}))
		return


func _on_game_menu_pressed():
	menu.open_in_game(best_score)


func _on_game_ended():
	if best_score < game.score:
		best_score = game.score
		save_best_score(best_score)
	
	menu.open_end_game(best_score, game.score)


func _on_menu_replay_pressed():
	if not is_instance_valid(game):
		return
	
	game.reset()
	game.start()
	menu.close()
