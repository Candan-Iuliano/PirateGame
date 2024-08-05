extends Node3D  # Change to Spatial if using Godot 3.x

# Exported variables to adjust in the editor
@export var move_speed : float = 10.0
@export var look_sensitivity : float = 0.1
@export var scroll_sensitivity : float = 0.1  # Adjust sensitivity for smoother scrolling
@export var scroll_smoothness : float = 5.0  # Higher values mean smoother transitions
# Internal variables for rotation
var is_right_button_pressed : bool = false
var yaw : float = 0.0
var pitch : float = 30.0  # Initial pitch value
var target_position : Vector3 = Vector3.ZERO
var smooth_velocity : float = 0.0

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
			target_position += Vector3.UP * scroll_sensitivity
			print(target_position)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_position -= Vector3.DOWN * scroll_sensitivity


	# Handle mouse motion input for rotation
	if event is InputEventMouseMotion and is_right_button_pressed:
		yaw -= event.relative.x * look_sensitivity
		pitch -= event.relative.y * look_sensitivity
		pitch = clamp(pitch, -45.0, 10.0)  # Clamp pitch to prevent flipping


func _process(delta: float) -> void:
	# Handle keyboard input for camera movement
	# Smoothly interpolate the camera position towards the target position
	var smooth_factor = min(scroll_smoothness * delta, 1.0)  # Ensure smooth_factor is clamped between 0 and 1
	if target_position != Vector3.ZERO:
		global_transform.origin = global_transform.origin.lerp(target_position, smooth_factor)
		target_position = Vector3.ZERO
	#print("Yaw:", yaw, "Pitch:", pitch, "Position:", transform.origin)
	
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
	#print(camera_basis.z, "   ", direction.z)
	direction = camera_basis.z * direction.z + camera_basis.x * direction.x

	# Project movement onto the horizontal plane (X-Z plane)
	direction.y = 0
	
	# Normalize direction to maintain consistent speed
	if direction != Vector3.ZERO:
		direction = direction.normalized() * move_speed * delta
		
		global_transform.origin += direction  # Apply movement to camera
	
	# Apply rotation
	set_pitch_yaw(pitch, yaw)
