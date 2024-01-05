extends RigidBody2D

var dead: bool = false
var dragging: bool = false
var released: bool = false
var start: Vector2 = Vector2.ZERO
var drag_start: Vector2 = Vector2.ZERO
var dragged: Vector2 = Vector2.ZERO
var last_dragged_position: Vector2 = Vector2.ZERO
var last_dragged_amount: float = 0.0
var fired_time: float = 0.0

func _ready():
	start = global_position

func _physics_process(delta):
	update_debug_label()

func update_debug_label() -> void:
	var info_str = "g_pos: %s\n" % Utils.vec2_to_str(global_position)
	info_str += "dragging: %s released: %s\n" % [dragging, released]
	info_str += "start: %s drag_start: %s\n" % [Utils.vec2_to_str(start), Utils.vec2_to_str(drag_start)]
	info_str += "last_dragged_pos: %s last_drag_amount: %0.1f\n" % [Utils.vec2_to_str(last_dragged_position), last_dragged_amount]
	info_str += "angular v: %0.1f linear v: %s fired_time: %0.1f" % [angular_velocity, Utils.vec2_to_str(linear_velocity), fired_time]
	SignalManager.on_update_debug_label.emit(info_str)

func grab() -> void:
	dragging = true
	drag_start = get_global_mouse_position()
	last_dragged_position = drag_start

func die() -> void:
	if dead:
		return
	
	dead = true
	SignalManager.on_animal_died.emit()
	queue_free()

func on_screen_exited():
	die()

func on_input_event(viewport, event: InputEvent, shape_idx):
	if dragging || released:
		return
	
	if event.is_action_pressed("drag"):
		grab()
