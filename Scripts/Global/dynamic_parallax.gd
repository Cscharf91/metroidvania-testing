class_name DynamicParallax
extends Parallax2D

var viewport_size: Vector2
@export var additional_offset: Vector2 = Vector2.ZERO
@export var background_color: Color

func _ready():
	$Sprite2D.visible = true

	if background_color:
		RenderingServer.set_default_clear_color(background_color)
	
	viewport_size = get_viewport_rect().size
	align_self()

func _process(_delta: float):
	var new_viewport_size = get_viewport_rect().size
	if viewport_size != new_viewport_size:
		viewport_size = new_viewport_size
		align_self()

func align_self():
	# scroll_offset.y = viewport_size.y / 2
	scroll_offset += additional_offset