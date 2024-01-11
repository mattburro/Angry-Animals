extends Node

const DEFAULT_SCORE: int = 1000

var level_scores: Dictionary = {}
var current_level: int = 0
var attempts: int = 0
var cups_hit: int = 0
var target_cups: int = 0

func _ready():
	SignalManager.on_cup_destroyed.connect(on_cup_destroyed)

func check_scores_for_level(level: int) -> void:
	if !level_scores.has(level):
		level_scores[level] = DEFAULT_SCORE

func level_selected(level: int) -> void:
	check_scores_for_level(level)
	current_level = level
	attempts = 0
	cups_hit = 0

func get_best_for_level(level: int) -> int:
	check_scores_for_level(level)
	return level_scores[level]

func attempt_made() -> void:
	attempts += 1
	SignalManager.on_attempt_made.emit()

func check_game_over() -> void:
	if cups_hit >= target_cups:
		print("GAME OVER")
		SignalManager.on_game_over.emit()
		if level_scores[current_level] > attempts:
			level_scores[current_level] = attempts
			print("Record set: ", level_scores)

func on_cup_destroyed() -> void:
	cups_hit += 1
	check_game_over()
