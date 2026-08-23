extends Area2D

const HEALTH_EFFECT:int = 20

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("heal")
