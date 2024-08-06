extends Node3D  # Change to Spatial if using Godot 3.x

# Exported variables to adjust in the editor
@export var move_speed : float = 10.0
@export var look_sensitivity : float = 0.1
@export var scroll_sensitivity : float = 2  # Adjust sensitivity for smoother scrolling
@export var scroll_smoothness : float = 50.0  # Higher values mean smoother transitions
@export var min_distance : float = 3.0  # Minimum distance from the hex grid
@export var max_distance : float = 8.0  # Maximum distance from the hex grid
# Internal variables for rotation
var is_right_button_pressed : bool = false
var yaw : float = 0.0
var pitch : float = 30.0  # Initial pitch value
var target_position : Vector3 = Vector3.ZERO
var zoom_speed : float = 10.0
var is_target_position_set : bool = false


func set_pitch_yaw(new_pitch: float, new_yaw: float) -> void:
	pitch = new_pitch
	yaw = new_yaw
	rotation_degrees.x = pitch
	rotation_degrees.y = yaw


func _input(event: InputEvent) -> void:
	# Handle mouse button input to toggle rotation
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			is_right_button_pressed = event.pressed  # Update button state
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			#print(target_position)
			#target_position += Vector3.DOWN
			target_position = global_transform.origin - global_transform.basis.z * scroll_sensitivity
			clamp_target_position(event)
			is_target_position_set = true
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			#target_position += Vector3.UP 
			target_position = global_transform.origin + global_transform.basis.z * scroll_sensitivity
			#print(target_position)
			clamp_target_position(event)
			is_target_position_set = true

	# Handle mouse motion input for rotation
	if event is InputEventMouseMotion and is_right_button_pressed:
		yaw -= event.relative.x * look_sensitivity
		pitch -= event.relative.y * look_sensitivity
		pitch = clamp(pitch, -45.0, -20)  # Clamp pitch to prevent flipping

func _process(delta: float) -> void:
	# Smoothly interpolate the camera position towards the target position
	if is_target_position_set:
		var smooth_factor = min(scroll_smoothness * delta, 1.0)  # Ensure smooth_factor is clamped between 0 and 1
		global_transform.origin = global_transform.origin.lerp(target_position, smooth_factor)
		# Stop interpolation when close enough to the target position
		if global_transform.origin.distance_to(target_position) < 0.1:
			global_transform.origin = target_position
			is_target_position_set = false  # Reset the flag to stop further movement
	
	var direction = Vector3.ZERO
	#pitch = -30
	if Input.is_action_pressed("move_forward"):
		direction += Vector3.FORWARD
	if Input.is_action_pressed("move_backward"):
		direction -= Vector3.FORWARD
	if Input.is_action_pressed("move_left"):
		direction -= Vector3.RIGHT
	if Input.is_action_pressed("move_right"):
		direction += Vector3.RIGHT
	# Convert direction from world space to camera's local space
	var camera_basis = global_transform.basis
	
	direction = camera_basis.z * direction.z + camera_basis.x * direction.x
	# Project movement onto the horizontal plane (X-Z plane)
	direction.y = 0

	# Normalize direction to maintain consistent speed
	if direction != Vector3.ZERO:
		direction = direction.normalized() * move_speed * delta
		global_transform.origin += direction 
	
	# Apply rotation
	set_pitch_yaw(pitch, yaw)
	
	
func clamp_target_position(event) -> void:
	# Clamp target_position distance from the origin
	var distance_to_origin = global_transform.origin.distance_to(Vector3.ZERO)
	print(global_transform.origin.y)
	#var global_transform.origin.y = distance_to_origin 
	if global_transform.origin.y <= min_distance:
		scroll_sensitivity = 0
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			print("HELLOO")
			scroll_sensitivity = 1
	elif global_transform.origin.y >= max_distance:
		scroll_sensitivity = 0
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			print("HELLOO")
			scroll_sensitivity = 1
