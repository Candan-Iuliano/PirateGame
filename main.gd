extends Node3D

@onready var camera : Camera3D = $Camera3D

func _ready():
	if camera == null:
		push_error("Camera3D node not found. Ensure the Camera3D node is correctly named and a child of this node.")
	else:
		# Initialization or setup for the camera if needed
		pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
