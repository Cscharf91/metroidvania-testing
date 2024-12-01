class_name DynamicParallax
extends Parallax2D

var viewport_size: Vector2

func _ready():
  viewport_size = get_viewport_rect().size
  align_self()

func _process(_delta: float):
  var new_viewport_size = get_viewport_rect().size
  if viewport_size != new_viewport_size:
    viewport_size = new_viewport_size
    align_self()

func align_self():
  scroll_offset.y = viewport_size.y / 2.5