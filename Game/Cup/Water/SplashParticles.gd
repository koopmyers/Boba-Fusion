extends Node2D


@onready var timer = $Timer
@onready var particle = $GPUParticles2D
@onready var audio_player = $AudioStreamPlayer2D


func _ready():
	audio_player.play()
	timer.wait_time = particle.lifetime
	timer.start()


func _on_Timer_timeout():
	queue_free()
