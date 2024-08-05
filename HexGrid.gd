extends Node3D

const TILE_SIZE := 1.0
const HEX_TILE = preload("res://hex_tile.tscn")

var grid_size := 10
@onready var camera : Camera3D = $"../Camera3D"  # Ensure this path is correct

# Called when the node enters the scene tree for the first time.
func _ready():
	_generate_grid()
	_setup_camera()

func _generate_grid():
	for x in range(grid_size):
		var tile_coordinates := Vector2.ZERO
		tile_coordinates.x = x * TILE_SIZE * cos(deg_to_rad(30))
		tile_coordinates.y = 0 if x % 2 == 0 else TILE_SIZE / 2
		for y in range(grid_size):
			var tile = HEX_TILE.instantiate()
			add_child(tile)
			tile.transform.origin = Vector3(tile_coordinates.x, 0, tile_coordinates.y)
			tile_coordinates.y += TILE_SIZE

func _setup_camera():
	if camera:
		# Calculate the dimensions of the grid
		var grid_width = grid_size * TILE_SIZE * cos(deg_to_rad(30))
		var grid_height = grid_size * TILE_SIZE
		
		# Calculate the center position of the grid
		var center = Vector3(grid_width / 2, 0, grid_height / 2)
		
		# Position the camera to view the grid
		var distance = max(grid_width, grid_height) * .5  # Adjust the multiplier if needed
		camera.transform.origin = center + Vector3(-1, distance, distance)
		
		# Apply rotation using the method
		camera.set_pitch_yaw(-30, 0)

	else:
		print("Camera node not found!")
