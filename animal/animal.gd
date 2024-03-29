extends RigidBody2D

@onready var stretch_sound = $StretchSound
@onready var launch_sound = $LaunchSound
@onready var collision_sound = $CollisionSound
@onready var arrow_sprite = $ArrowSprite

const DRAG_LIMIT_MAX: Vector2 = Vector2(0, 60)
const DRAG_LIMIT_MIN: Vector2 = Vector2(-60, 0)
const IMPULSE_MULTIPLIER: float = 20.0
const IMPULSE_MAX: float = 1200.0
const FIRE_DELAY: float = 0.25
const STOP_THRESHOLD: float = 0.1

var dead: bool = false
var dragging: bool = false
var released: bool = false
var start: Vector2 = Vector2.ZERO
var drag_start: Vector2 = Vector2.ZERO
var dragged_vector: Vector2 = Vector2.ZERO
var last_dragged_position: Vector2 = Vector2.ZERO
var last_dragged_amount: float = 0.0
var fired_time: float = 0.0
var arrow_scale_x: float = 0.0
var last_collision_count: int = 0

func _ready():
	start = global_position
	arrow_scale_x = arrow_sprite.scale.x
	arrow_sprite.hide()

func _physics_process(delta):
	update_debug_label()
	
	if released:
		fired_time += delta
		if fired_time > FIRE_DELAY:
			check_play_collision()
			check_on_target()
	else:
		if !dragging:
			return
		else:
			if Input.is_action_just_released("drag"):
				release()
			else:
				drag()

func update_debug_label() -> void:
	var info_str = "g_pos: %s contacts: %s\n" % [Utils.vec2_to_str(global_position), get_contact_count()]
	info_str += "dragging: %s released: %s\n" % [dragging, released]
	info_str += "start: %s drag_start: %s dragged_vector: %s\n" % [Utils.vec2_to_str(start), Utils.vec2_to_str(drag_start), Utils.vec2_to_str(dragged_vector)]
	info_str += "last_dragged_pos: %s last_drag_amount: %0.1f\n" % [Utils.vec2_to_str(last_dragged_position), last_dragged_amount]
	info_str += "angular v: %0.1f linear v: %s fired_time: %0.1f" % [angular_velocity, Utils.vec2_to_str(linear_velocity), fired_time]
	SignalManager.on_update_debug_label.emit(info_str)

func scale_arrow() -> void:
	var impulse_length = get_impulse().length()
	var impulse_percentage = impulse_length / IMPULSE_MAX
	
	arrow_sprite.scale.x = (arrow_scale_x * impulse_percentage) + arrow_scale_x
	arrow_sprite.rotation = (start - global_position).angle()

func stopped_moving() -> bool:
	if get_contact_count() > 0:
		if abs(linear_velocity.y) < STOP_THRESHOLD && abs(angular_velocity) < STOP_THRESHOLD:
			return true
	
	return false

func check_on_target():
	if !stopped_moving():
		return
	
	var colliding_bodies = get_colliding_bodies()
	if colliding_bodies.size() == 0:
		return
	
	var cup = colliding_bodies[0]
	
	if cup.is_in_group(GameManager.GROUP_CUP):
		cup.die()
		die()

func check_play_collision() -> void:
	if last_collision_count == 0 && get_contact_count() > 0:
		collision_sound.play()
	
	last_collision_count = get_contact_count()

func grab() -> void:
	dragging = true
	drag_start = get_global_mouse_position()
	last_dragged_position = drag_start
	arrow_sprite.show()

func drag() -> void:
	var global_mouse_pos = get_global_mouse_position()
	last_dragged_amount = (last_dragged_position - global_mouse_pos).length()
	last_dragged_position = global_mouse_pos
	
	if last_dragged_amount > 0 && !stretch_sound.playing:
		stretch_sound.play()
	
	dragged_vector = global_mouse_pos - drag_start
	dragged_vector.x = clampf(dragged_vector.x, DRAG_LIMIT_MIN.x, DRAG_LIMIT_MAX.x)
	dragged_vector.y = clampf(dragged_vector.y, DRAG_LIMIT_MIN.y, DRAG_LIMIT_MAX.y)
	global_position = start + dragged_vector
	
	scale_arrow()

func release():
	dragging = false
	released = true
	freeze = false
	
	apply_central_impulse(get_impulse())
	stretch_sound.stop()
	launch_sound.play()
	arrow_sprite.hide()
	
	ScoreManager.attempt_made()

func get_impulse() -> Vector2:
	return dragged_vector * -1 * IMPULSE_MULTIPLIER

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
