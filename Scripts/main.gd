extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label.visible = false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("UI"):
		$Label.visible = !$Label.visible
