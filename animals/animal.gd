extends RigidBody2D

func _physics_process(delta):
	update_debug_label()

func update_debug_label() -> void:
	var info_str = "g_pos: %s\n" % Utils.vec2_to_str(global_position)
	info_str += "angular v: %0.1f\nlinear v: %s" % [angular_velocity, Utils.vec2_to_str(linear_velocity)]
	SignalManager.on_update_debug_label.emit(info_str)
