extends Node

const DEFAULT_SCORE: int = 1000

var level_scores: Dictionary = {}
var level: int = 0
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
	level = level
	attempts = 0
	cups_hit = 0

func get_best_for_level(level: int) -> int:
	check_scores_for_level(level)
	return level_scores[level]

func on_cup_destroyed() -> void:
	cups_hit += 1
