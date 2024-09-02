extends CharacterBody3D


@onready var camera = $SpringArm3D/ThirdPersonCamera
@onready var spring_arm = $SpringArm3D
@export var model:Node3D = null
@onready var fps_camera = $"X Bot/FPSContainer/FPSCam"

@export_group("Flight Mode Properties")
@export_subgroup("Speed")
@export_range(1, 100, 0.5) var speed: float = 10
@export_range(1, 3, 0.1) var turbo_modifier: float = 2
@export_subgroup("Yaw")
@export_range(1, 100) var yaw_speed: float = 10
@export_range(10, 180, 1) var max_yaw: int = 70
@export_subgroup("Roll")
@export_range(1, 100) var max_roll: int = 70
@export_range(3, 10, 0.5) var pitch_speed: float = 10
@export_subgroup("Pitch")
@export_range(10, 180, 1) var max_pitch: int = 30
@export_range(3, 10, 0.5) var turbo_time: float = 5

var grounded = false
#var camera_modes = [camera, pov_camera]
enum camera_modes {FPS, TPS}
var camera_mode = camera_modes.TPS

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	#fps_camera.active = false
	pass

func _physics_process(delta):
	
	flight(delta)
	pass

func flight(delta):
	##Limit first person camera's mouse movement effect on pitch yaw roll
	##Add movement effect on pitch yaw roll based on WASD
	if camera_mode == camera_modes.FPS:
		_move(delta)
		pass
	if camera_mode == camera_modes.TPS:
		_move(delta)
		_pitch(delta)
		_yaw(delta)
	pass

func _move(delta):
	position -= transform.basis.z * delta * speed
	pass

func _pitch(delta):
	var mouse_speed = _get_mouse_speed()
	rotation_degrees.x += mouse_speed.y * delta * pitch_speed
	var amount = abs(mouse_speed.y)
	var direction = sign(mouse_speed.y)
	model.rotation_degrees.x = lerp(0, max_pitch, amount) * direction
	pass

func _yaw(delta):
	var mouse_speed = _get_mouse_speed()
	rotation_degrees.y += mouse_speed.x * delta * pitch_speed
	_roll_and_yaw_model(mouse_speed.x, delta)
	pass

func _roll_and_yaw_model(mouse_speed_x: float, delta: float) -> void:
	var amount = abs(mouse_speed_x)
	var direction = sign(mouse_speed_x)
	model.rotation_degrees.y = lerp(0, max_yaw, amount) * direction
	model.rotation_degrees.y = lerp(0, max_roll, amount) * direction
	pass


func get_move_input(delta):
	pass

func _get_mouse_speed() -> Vector2:
	var screen_center = get_viewport().size * 0.5
	var displacement = screen_center - get_viewport().get_mouse_position()
	displacement.x /= screen_center.x
	displacement.y /= screen_center.y
	print(displacement)
	return displacement
	#return Vector2.ZERO
	pass

func _unhandled_input(event):
	##TODO: Main menu
	if Input.is_action_just_pressed("escape"):
		if Input.mouse_mode == Input.MOUSE_MODE_CONFINED:
			Input.mouse_mode = 0
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	if Input.is_action_just_pressed("camera_toggle"):
		if camera_mode == camera_modes.TPS:
			fps_camera.current = true
			#camera.active = false
			camera_mode = camera_modes.FPS
		else:
			#fps_camera.active = false
			camera.current = true
			camera_mode = camera_modes.TPS
		pass
	#if event is InputEventMouseMotion:
		#spring_arm.rotation.x -= event.relative.y * mouse_sensitivity
		#spring_arm.rotation_degrees.x = clamp(spring_arm.rotation_degrees.x, -90, 30)
		#spring_arm.rotation.y -= event.relative.x * mouse_sensitivity
	pass
