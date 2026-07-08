extends Camera3D
class_name RTSCamera

# =========================
# Camera movement settings
# =========================
@export_category("Camera movement")
@export var camera_speed: float = 20.0
@export var camera_zoom_step: float = 20.0
@export var camera_zoom_min: float = 10.0
@export var camera_zoom_max: float = 50.0

# =========================
# Edge scrolling settings
# =========================
@export_category("Edge Scrolling")
@export var edge_scroll_margin: float = 20.0

# =========================
# Rotation (RMB) settings
# =========================
@export_category("Rotation")
# Fractions of a full turn (TAU) for dragging across the *shorter* screen.
@export var yaw_sensitivity: float = 0.50
@export var pitch_sensitivity: float = 0.18
@export var pitch_min_deg: float = 10.0
@export var pitch_max_deg: float = 80.0
@export var capture_mouse_on_RMB_drag: bool = true


@export_category("Smoothing")
@export_range(0.0, 0.4, 0.01) var pan_smoothing: float = 0.15
@export_range(0.0, 0.4, 0.01) var zoom_smoothing: float = 0.12
@export_range(0.0, 0.4, 0.01) var rotation_smoothing: float = 0.12


var orbit_center: Vector3 = Vector3.ZERO
var orbit_distance: float = 10.0
var _yaw: float = 0.0
var _pitch: float = 0.8               # radians (~45 deg initial)

# Derived values (other systems may read these)
var current_height: float = 20.0
var orbit_radius: float = 20.0

# =========================
# Goal state  -- input only ever writes to these
# =========================
var _center_goal: Vector3 = Vector3.ZERO
var _distance_goal: float = 25.0
var _yaw_goal: float = 0.0
var _pitch_goal: float = 0.8

# =========================
# Spring velocities  -- carried between frames, this is what creates inertia
# =========================
var _center_vel: Vector3 = Vector3.ZERO
var _distance_vel: float = 0.0
var _yaw_vel: float = 0.0
var _pitch_vel: float = 0.0

var _is_rmb_dragging := false


func _ready() -> void:
	var pmin := deg_to_rad(pitch_min_deg)
	var pmax := deg_to_rad(pitch_max_deg)
	_pitch = clamp(_pitch, pmin, pmax)

	_center_goal = orbit_center
	_distance_goal = orbit_distance
	_yaw_goal = _yaw
	_pitch_goal = _pitch

	_update_camera_position()


func _process(delta: float) -> void:

	var movement := Vector3.ZERO

	if Input.is_action_pressed("ui_right"):
		movement.x += 1
	if Input.is_action_pressed("ui_left"):
		movement.x -= 1
	if Input.is_action_pressed("ui_up"):
		movement.z -= 1
	if Input.is_action_pressed("ui_down"):
		movement.z += 1

	var mouse_pos := get_viewport().get_mouse_position()
	var viewport_size = get_viewport().size
	if mouse_pos.x < edge_scroll_margin:
		movement.x -= 1
	elif mouse_pos.x > viewport_size.x - edge_scroll_margin:
		movement.x += 1
	if mouse_pos.y < edge_scroll_margin:
		movement.z -= 1
	elif mouse_pos.y > viewport_size.y - edge_scroll_margin:
		movement.z += 1

	var speed_multiplier := 2.0 if Input.is_action_pressed("ui_shift") else 1.0

	if movement.length() > 0.0:
		movement = movement.normalized().rotated(Vector3.UP, _yaw)
		_center_goal += movement * camera_speed * speed_multiplier * delta

	var r: Vector2

	r = _sd1(_yaw, _yaw_goal, _yaw_vel, rotation_smoothing, delta)
	_yaw = r.x
	_yaw_vel = r.y

	r = _sd1(_pitch, _pitch_goal, _pitch_vel, rotation_smoothing, delta)
	_pitch = r.x
	_pitch_vel = r.y

	r = _sd1(orbit_distance, _distance_goal, _distance_vel, zoom_smoothing, delta)
	orbit_distance = r.x
	_distance_vel = r.y

	var cx := _sd1(orbit_center.x, _center_goal.x, _center_vel.x, pan_smoothing, delta)
	var cy := _sd1(orbit_center.y, _center_goal.y, _center_vel.y, pan_smoothing, delta)
	var cz := _sd1(orbit_center.z, _center_goal.z, _center_vel.z, pan_smoothing, delta)
	orbit_center = Vector3(cx.x, cy.x, cz.x)
	_center_vel = Vector3(cx.y, cy.y, cz.y)

	_update_camera_position()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		# Wheel zoom -> only moves the zoom GOAL; the spring eases there.
		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_distance_goal = max(camera_zoom_min, _distance_goal - camera_zoom_step)
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_distance_goal = min(camera_zoom_max, _distance_goal + camera_zoom_step)

		# Start/stop rotate+tilt with Right Mouse.
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_is_rmb_dragging = event.pressed
			if capture_mouse_on_RMB_drag:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if event.pressed else Input.MOUSE_MODE_VISIBLE)
			# accept_event()  # uncomment if UI shouldn't also consume RMB

	elif event is InputEventMouseMotion and _is_rmb_dragging:
		# Map drag straight onto the rotation GOAL. No dt, no per-event clamp:
		# the smoothing in _process handles the feel.
		var vp = get_viewport().size
		var vmin := float(min(vp.x, vp.y))   # normalize by the shorter side

		_yaw_goal   -= (event.relative.x / vmin) * yaw_sensitivity   * TAU
		_pitch_goal += (event.relative.y / vmin) * pitch_sensitivity * TAU

		var pmin := deg_to_rad(pitch_min_deg)
		var pmax := deg_to_rad(pitch_max_deg)
		_pitch_goal = clamp(_pitch_goal, pmin, pmax)


# =========================
# Helpers
# =========================
func _update_camera_position() -> void:
	# Spherical direction from yaw/pitch.
	var dir := Vector3(
		sin(_yaw) * cos(_pitch),
		sin(_pitch),
		cos(_yaw) * cos(_pitch)
	).normalized()

	position = orbit_center + dir * orbit_distance
	look_at(orbit_center, Vector3.UP)

	current_height = orbit_distance * sin(_pitch)
	orbit_radius   = orbit_distance * cos(_pitch)


@warning_ignore("shadowed_variable_base_class")
func _sd1(current: float, target: float, vel: float, smooth_time: float, dt: float) -> Vector2:
	if dt <= 0.0:
		return Vector2(current, vel)
	if smooth_time <= 0.0:
		return Vector2(target, 0.0)

	# Halved to keep "seconds-to-rest" feel matching the 2D script.
	smooth_time /= 2.0

	var omega := 2.0 / smooth_time
	var x := omega * dt
	var expo := 1.0 / (1.0 + x + 0.48 * x * x + 0.235 * x * x * x)

	var change := current - target
	var original_to := target

	var temp := (vel + omega * change) * dt
	var new_vel := (vel - omega * temp) * expo
	var output := target + (change + temp) * expo

	# Prevent overshoot.
	if (original_to > current) == (output > original_to):
		output = original_to
		new_vel = (output - original_to) / dt

	return Vector2(output, new_vel)


# =========================
# Framing settings
# =========================
@export_category("Framing")
## Extra world-units of breathing room added around framed targets.
@export var framing_padding: float = 2.0


## Re-aims the camera so every given world position is on screen at once, panning
## the orbit centre and adjusting zoom (within min/max). Only writes GOALS — the
## springs in _process produce the actual smooth pan. Yaw and pitch are untouched:
## the bounding-sphere fit is valid from any viewing angle.
func frame_positions(positions: Array[Vector3], padding: float = -1.0) -> void:
	if positions.is_empty():
		return
	if padding < 0.0:
		padding = framing_padding

	# Bounding sphere: AABB centre, then the real max radius from it.
	var min_p := positions[0]
	var max_p := positions[0]
	for p in positions:
		min_p = min_p.min(p)
		max_p = max_p.max(p)
	var centre := (min_p + max_p) * 0.5

	var radius := 0.0
	for p in positions:
		radius = maxf(radius, centre.distance_to(p))
	radius += padding

	_center_goal = centre
	_distance_goal = clampf(_distance_for_radius(radius), camera_zoom_min, camera_zoom_max)


## Distance at which a sphere of `radius` centred on the orbit centre fits fully
## inside the frustum. Camera3D.fov is vertical (KEEP_HEIGHT default); the
## horizontal FOV follows from the aspect ratio, and the narrower axis limits.
func _distance_for_radius(radius: float) -> float:
	var v_fov := deg_to_rad(fov)
	var aspect := get_viewport().get_visible_rect().size.aspect()
	var h_fov := 2.0 * atan(tan(v_fov * 0.5) * aspect)
	var limiting := minf(v_fov, h_fov)
	return radius / sin(limiting * 0.5)
