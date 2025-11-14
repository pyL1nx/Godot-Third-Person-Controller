extends CharacterBody3D

@onready var camera_mount = $"Camera mount"
@onready var animation_player: AnimationPlayer = $visuals/mixamo_base/AnimationPlayer
@onready var visuals: Node3D = $visuals

# VALUES 
@export_group("Player Controller")

@export_subgroup("Movement")
var SPEED = 3.0
@export var JUMP_VELOCITY = 4.5

@export var walking_speed = 3.0
@export var running_speed = 5.0
var running = false

@export_subgroup("Sensitivity Settings")
@export var horizontal_sensitivity = 0.5
@export var vertical_sensitivity = 0.5

# Vertical camera limits
var min_look_angle := deg_to_rad(-80)
var max_look_angle := deg_to_rad(80)

var is_locked = false



func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED



func _input(event: InputEvent) -> void:

	# Unlock mouse
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return   # stop camera rotation this frame

	# lock mouse 
	if event is InputEventMouseButton and event.pressed:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			return  # don't rotate camera instantly on this click
			
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return

	# Mouse look control
	if event is InputEventMouseMotion:
		# Yaw rotation (left-right)
		rotate_y(deg_to_rad(-event.relative.x * horizontal_sensitivity))
		visuals.rotate_y(deg_to_rad(event.relative.x * horizontal_sensitivity))

		# Pitch rotation (up-down)
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * vertical_sensitivity))

		# Clamp vertical rotation
		camera_mount.rotation.x = clamp(camera_mount.rotation.x, min_look_angle, max_look_angle)



func _physics_process(delta: float) -> void:

	# Kick
	if !animation_player.is_playing():
		is_locked = false

	if Input.is_action_just_pressed("kick"):
		if animation_player.current_animation != "kick":
			animation_player.play("kick")
			is_locked = true

	# Running toggle
	if Input.is_action_pressed("run"):
		SPEED = running_speed
		running = true
	else:
		SPEED = walking_speed
		running = false

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movement input
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		if !is_locked:
			if running:
				if animation_player.current_animation != "running":
					animation_player.play("running")
			else:
				if animation_player.current_animation != "walking":
					animation_player.play("walking")

			visuals.look_at(position + direction)

		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED

	else:
		if !is_locked:
			if animation_player.current_animation != "idle":
				animation_player.play("idle")

		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if !is_locked:
		move_and_slide()
