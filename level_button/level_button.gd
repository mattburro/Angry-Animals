extends TextureButton

const DEFAULT_SCALE: Vector2 = Vector2.ONE
const HOVER_SCALE: Vector2 = Vector2(1.1, 1.1)

@export var level_number: int = 1

@onready var level_label = $MarginContainer/VBoxContainer/LevelLabel
@onready var score_label = $MarginContainer/VBoxContainer/ScoreLabel

var level_scene: PackedScene

func _ready():
	level_label.text = str(level_number)
	level_scene = load("res://level/level_%s.tscn" % level_number)

func on_pressed():
	get_tree().change_scene_to_packed(level_scene)

func on_mouse_entered():
	scale = HOVER_SCALE

func on_mouse_exited():
	scale = DEFAULT_SCALE
