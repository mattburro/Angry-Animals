extends CanvasLayer

@onready var level_label = $MarginContainer/VBoxContainer/LevelLabel
@onready var attempts_label = $MarginContainer/VBoxContainer/AttemptsLabel
@onready var v_box_container_2 = $MarginContainer/VBoxContainer2
@onready var sound = $Sound

func _ready():
	level_label.text = "Level %s" % ScoreManager.current_level
	on_attempt_made()
	SignalManager.on_attempt_made.connect(on_attempt_made)
	SignalManager.on_game_over.connect(on_game_over)

func _process(delta):
	if v_box_container_2.visible && Input.is_key_pressed(KEY_SPACE):
		GameManager.load_main_scene()

func on_attempt_made() -> void:
	attempts_label.text = "Attempts: %s" % ScoreManager.attempts

func on_game_over() -> void:
	v_box_container_2.show()
	sound.play()
