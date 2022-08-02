class_name ZoomingCamera2D
extends Camera2D

# Lower cap for the `_zoom_level`.
export var min_zoom := 0.2
# Upper cap for the `_zoom_level`.
export var max_zoom := 600.0
# Controls how much we increase or decrease the `_zoom_level` on every turn of the scroll wheel.
export var zoom_factor := 0.3
# Duration of the zoom's tween animation.
export var zoom_duration := 0.2

export var movement_speed = 500

# The camera's target zoom level.
var _zoom_level := 1.0 setget _set_zoom_level

# We store a reference to the scene's tween node.
onready var tween: Tween = $Tween

var dir = Vector2.ZERO

func _set_zoom_level(value: float) -> void:
	# We limit the value between `min_zoom` and `max_zoom`
	_zoom_level = clamp(value, min_zoom, max_zoom)
	
	var prev_zoom = zoom
	var ratio = _zoom_level/prev_zoom.x
	var mouse_move = (get_local_mouse_position()*ratio) - get_local_mouse_position()
	print(mouse_move)
	
	tween.interpolate_property(
		self,
		"zoom",
		zoom,
		Vector2(_zoom_level, _zoom_level),
		zoom_duration,
		tween.TRANS_SINE,
		# Easing out means we start fast and slow down as we reach the target value.
		tween.EASE_OUT
	)
	
	#moves the camera so that it always zooms on the mouse
	tween.interpolate_property(
		self,
		"position",
		position,
		Vector2(position.x-mouse_move.x, position.y-mouse_move.y),
		zoom_duration,
		tween.TRANS_SINE,
		# Easing out means we start fast and slow down as we reach the target value.
		tween.EASE_OUT
	)
	
	
	tween.start()

func _unhandled_input(event):
	var factor = zoom_factor*zoom.x/2
	if event.is_action_pressed("zoom_in"):
		
		_set_zoom_level(_zoom_level - factor)
	if event.is_action_pressed("zoom_out"):
		_set_zoom_level(_zoom_level + factor)
	
	
	elif event.is_action_pressed("down"):
		dir += Vector2.DOWN
	elif event.is_action_pressed("up"):
		dir += Vector2.UP
	elif event.is_action_pressed("left"):
		dir += Vector2.LEFT
	elif event.is_action_pressed("right"):
		dir += Vector2.RIGHT
	
func _input(event):
	if Input.is_action_just_released("down"):
		dir.y = 0
		if Input.is_action_pressed("up"):
			dir.y =-1
	elif Input.is_action_just_released("up"):
		dir.y = 0
		if Input.is_action_pressed("down"):
			dir.y =1
	elif Input.is_action_just_released("left"):
		dir.x = 0
		if Input.is_action_pressed("right"):
			dir.x =1
	elif Input.is_action_just_released("right"):
		dir.x = 0
		if Input.is_action_pressed("left"):
			dir.x =-1

func _process(delta):
	position+=dir*zoom*delta*movement_speed
