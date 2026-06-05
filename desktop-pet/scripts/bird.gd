extends Node2D
## Bird node — procedural drawing, animation state machine, and behavior

enum State { IDLE, WALK, SLEEP }

var species_data: Dictionary
var state: State = State.IDLE
var facing_right: bool = true

# Animation parameters
var float_time: float = 0.0
var float_amplitude: float = 5.0
var float_frequency: float = 2.0
var idle_position_y: float

# Walk parameters
var walk_speed: float = 60.0
var walk_target_x: float = 0.0
var walk_direction: float = 1.0

# Sleep timer
var sleep_timer: float = 0.0
const SLEEP_THRESHOLD: float = 60.0

# Blink timer
var blink_timer: float = 0.0
var is_blinking: bool = false
var blink_duration: float = 0.1

# Walk timer
var state_timer: float = 0.0
var state_duration: float = 3.0

# Eye look offset
var eye_look_offset: float = 0.0

# Movement bounds (relative to bird node)
var bound_left: float = -120.0
var bound_right: float = 120.0


func _ready():
	idle_position_y = position.y
	set_species(BirdData.get_species(BirdData.DEFAULT_ENVIRONMENT))


func set_species(data: Dictionary):
	species_data = data
	queue_redraw()


func get_bird_name() -> String:
	return species_data.get("name", "未知鸟")


func get_environment() -> String:
	for env in BirdData.SPECIES:
		if BirdData.SPECIES[env]["name"] == species_data.get("name", ""):
			return env
	return "unknown"


func _process(delta: float):
	_update_state(delta)
	_update_animation(delta)
	_update_walk(delta)
	queue_redraw()


func _update_state(delta: float):
	# Update sleep timer
	sleep_timer += delta
	if sleep_timer >= SLEEP_THRESHOLD and state != State.SLEEP:
		_enter_state(State.SLEEP)

	# State timer for idle/walk transitions
	if state != State.SLEEP:
		state_timer -= delta
		if state_timer <= 0.0:
			if state == State.IDLE:
				_enter_state(State.WALK)
			else:
				_enter_state(State.IDLE)


func _enter_state(new_state: State):
	state = new_state
	match state:
		State.IDLE:
			state_duration = randf_range(2.0, 5.0)
			state_timer = state_duration
		State.WALK:
			state_duration = randf_range(2.0, 5.0)
			state_timer = state_duration
			# Pick random direction
			if randi() % 2 == 0:
				facing_right = true
				walk_direction = 1.0
			else:
				facing_right = false
				walk_direction = -1.0
			# Pick random walk target
			var walk_distance = randf_range(50.0, 180.0)
			walk_target_x = position.x + walk_direction * walk_distance
			walk_target_x = clamp(walk_target_x, bound_left, bound_right)
		State.SLEEP:
			pass


func _update_animation(delta: float):
	float_time += delta

	match state:
		State.IDLE:
			float_frequency = 2.0
			float_amplitude = 5.0
		State.WALK:
			float_frequency = 5.0
			float_amplitude = 3.0
		State.SLEEP:
			float_frequency = 1.0
			float_amplitude = 2.0

	# Blink logic
	blink_timer -= delta
	if blink_timer <= 0.0:
		if is_blinking:
			is_blinking = false
			blink_timer = randf_range(2.0, 4.0)
		else:
			is_blinking = true
			blink_timer = blink_duration


func _update_walk(delta: float):
	if state == State.WALK:
		var move = walk_direction * walk_speed * delta
		position.x += move
		# Check if reached target
		if abs(position.x - walk_target_x) < 5.0:
			_enter_state(State.IDLE)
		# Check bounds
		if position.x <= bound_left or position.x >= bound_right:
			_enter_state(State.IDLE)


func _draw():
	if species_data.is_empty():
		return

	var y_offset = sin(float_time * float_frequency * PI) * float_amplitude
	var draw_y = y_offset

	# Determine if eyes are closed (blinking or sleeping)
	var eyes_closed = is_blinking
	if state == State.SLEEP:
		eyes_closed = true

	_draw_shadow(draw_y)
	_draw_body(draw_y)
	_draw_head(draw_y, eyes_closed)
	_draw_feet(draw_y)
	_draw_wings(draw_y)


func _draw_shadow(y_offset: float):
	var bh: float = species_data["body_height"]
	var bw: float = species_data["body_width"]
	var shadow_y = y_offset + bh * 0.55
	var shadow_radius = bw * 0.45
	# Soft shadow under bird
	draw_circle(Vector2(0, shadow_y), shadow_radius, Color(0, 0, 0, 0.12))


func _draw_body(y_offset: float):
	var body_color: Color = species_data["body_color"]
	var belly_color: Color = species_data["belly_color"]
	var bw: float = species_data["body_width"]
	var bh: float = species_data["body_height"]
	var fat: float = species_data["fatness"]

	# Draw body ellipse
	draw_circle(Vector2(0, y_offset + bh * 0.15), bh * 0.55 * fat, body_color)

	# Draw belly (lighter front)
	var belly_pos = Vector2(bh * 0.1 * fat, y_offset + bh * 0.2)
	draw_circle(belly_pos, bh * 0.35 * fat, belly_color)


func _draw_head(y_offset: float, eyes_closed: bool):
	var body_color: Color = species_data["body_color"]
	var beak_color: Color = species_data["beak_color"]
	var head_r: float = species_data["head_radius"]
	var beak_l: float = species_data["beak_length"]
	var beak_w: float = species_data["beak_width"]
	var bh: float = species_data["body_height"]

	var head_pos = Vector2(0, y_offset - bh * 0.35)

	# Draw head
	draw_circle(head_pos, head_r, body_color)

	# Draw crest if present
	if species_data.get("crest", false):
		var crest_color: Color = species_data["crest_color"]
		var crest_points = PackedVector2Array([
			Vector2(-4, -head_r - 8 + y_offset - bh * 0.35),
			Vector2(0, -head_r - 18 + y_offset - bh * 0.35),
			Vector2(4, -head_r - 6 + y_offset - bh * 0.35),
		])
		draw_polygon(crest_points, PackedColorArray([crest_color, crest_color, crest_color]))
		crest_points = PackedVector2Array([
			Vector2(0, -head_r - 5 + y_offset - bh * 0.35),
			Vector2(5, -head_r - 16 + y_offset - bh * 0.35),
			Vector2(9, -head_r - 3 + y_offset - bh * 0.35),
		])
		draw_polygon(crest_points, PackedColorArray([crest_color, crest_color, crest_color]))

	# Draw beak
	var beak_dir = 1.0 if facing_right else -1.0
	var beak_start = head_pos + Vector2(beak_dir * head_r * 0.8, 2)
	var beak_tip = beak_start + Vector2(beak_dir * beak_l, 0)
	var beak_top = beak_start + Vector2(beak_dir * beak_l * 0.3, -beak_w * 0.5)
	var beak_bottom = beak_start + Vector2(beak_dir * beak_l * 0.3, beak_w * 0.5)
	draw_polygon(
		PackedVector2Array([beak_start, beak_tip, beak_bottom]),
		PackedColorArray([beak_color, beak_color, beak_color])
	)

	# Draw eyes
	var eye_color = Color.WHITE
	var pupil_color = Color.BLACK
	var eye_radius: float = head_r * 0.35
	var eye_offset_x: float = head_r * 0.35
	var eye_offset_y: float = -2.0

	var left_eye_pos = head_pos + Vector2(-eye_offset_x + eye_look_offset, eye_offset_y)
	var right_eye_pos = head_pos + Vector2(eye_offset_x + eye_look_offset, eye_offset_y)

	if eyes_closed:
		# Draw closed eyes as lines
		draw_line(
			left_eye_pos + Vector2(-eye_radius, 0),
			left_eye_pos + Vector2(eye_radius, 0),
			pupil_color, 2
		)
		draw_line(
			right_eye_pos + Vector2(-eye_radius, 0),
			right_eye_pos + Vector2(eye_radius, 0),
			pupil_color, 2
		)
	else:
		# Left eye
		draw_circle(left_eye_pos, eye_radius, eye_color)
		draw_circle(left_eye_pos + Vector2(eye_look_offset * 0.5, 0), eye_radius * 0.5, pupil_color)
		# Right eye
		draw_circle(right_eye_pos, eye_radius, eye_color)
		draw_circle(right_eye_pos + Vector2(eye_look_offset * 0.5, 0), eye_radius * 0.5, pupil_color)


func _draw_wings(y_offset: float):
	var wing_color: Color = species_data["wing_color"]
	var bw: float = species_data["body_width"]
	var bh: float = species_data["body_height"]

	# Small wings on sides of body
	var wing_sway = sin(float_time * 2.0) * 3.0

	# Left wing
	var left_wing_points = PackedVector2Array([
		Vector2(-bw * 0.35, -bh * 0.1 + y_offset),
		Vector2(-bw * 0.55, -bh * 0.25 + wing_sway + y_offset),
		Vector2(-bw * 0.45, -bh * 0.05 + y_offset),
	])
	draw_polygon(left_wing_points, PackedColorArray([wing_color, wing_color, wing_color]))

	# Right wing
	var right_wing_points = PackedVector2Array([
		Vector2(bw * 0.35, -bh * 0.1 + y_offset),
		Vector2(bw * 0.55, -bh * 0.25 - wing_sway + y_offset),
		Vector2(bw * 0.45, -bh * 0.05 + y_offset),
	])
	draw_polygon(right_wing_points, PackedColorArray([wing_color, wing_color, wing_color]))


func _draw_feet(y_offset: float):
	var foot_color = Color(1.0, 0.6, 0.25)
	var bh: float = species_data["body_height"]

	var left_foot_x = -6.0
	var right_foot_x = 6.0
	var foot_y = y_offset + bh * 0.5

	# Simple feet
	draw_line(Vector2(left_foot_x, foot_y), Vector2(left_foot_x - 6, foot_y + 5), foot_color, 2)
	draw_line(Vector2(left_foot_x, foot_y), Vector2(left_foot_x + 4, foot_y + 5), foot_color, 2)
	draw_line(Vector2(right_foot_x, foot_y), Vector2(right_foot_x - 6, foot_y + 5), foot_color, 2)
	draw_line(Vector2(right_foot_x, foot_y), Vector2(right_foot_x + 4, foot_y + 5), foot_color, 2)


## Called when mouse enters the bird area — reset sleep
func _on_mouse_entered():
	sleep_timer = 0.0
	if state == State.SLEEP:
		_enter_state(State.IDLE)
	eye_look_offset = 2.0


## Called when mouse exits the bird area
func _on_mouse_exited():
	sleep_timer = 0.0
	eye_look_offset = 0.0


## Called when any input is detected — reset sleep timer
func notify_interaction():
	sleep_timer = 0.0
	if state == State.SLEEP:
		_enter_state(State.IDLE)
