extends StaticBody2D

@onready var animation_player = $AnimationPlayer
@onready var vanish_sound = $VanishSound

func die() -> void:
	vanish_sound.play()
	animation_player.play("vanish")
	
	await vanish_sound.finished && animation_player.animation_finished
	SignalManager.on_cup_destroyed.emit()
	queue_free()
