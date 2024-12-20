class_name CameraShake
extends Node2D

@onready var noise_emitter: PhantomCameraNoiseEmitter2D = %PhantomCameraNoiseEmitter2D

@export var default_amplitude := 20.0
@export var default_duration := 0.5

func _ready() -> void:
	Events.screen_shake.connect(_on_screen_shake)

func start_shake(amplitude: float = default_amplitude, duration: float = default_duration) -> void:
	if noise_emitter.has_method("emit"):
		noise_emitter.noise.amplitude = amplitude
		noise_emitter.duration = duration
		noise_emitter.emit()

func _on_screen_shake(amplitude: float, duration: float) -> void:
	start_shake(amplitude, duration)
