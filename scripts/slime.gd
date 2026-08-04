extends CharacterBody2D

const SPEED: int = 100
const KNOCKBACK_FORCE: int = 100

var target = null
var health:int = 100

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var take_damage_audio = $TakeDamage

func _physics_process(delta):
	if target:
		_attack(delta)
	
func _attack(delta: float) -> void:
	var direction = (target.position - position).normalized()
	position += direction * SPEED * delta
	animated_sprite_2d.play("attack")

func take_damage(damage: int, attaker_position: Vector2) -> void:
	health -= damage
	take_damage_audio.play()
	# knockback
	var knockback_direction = (position - attaker_position).normalized()
	var target_position = position + knockback_direction * KNOCKBACK_FORCE
	var tween = create_tween()
	tween.tween_property(self, "position", target_position, 0.5)

func _on_sight_body_entered(body):
	if body.name == "Player":
		target = body


func _on_sight_body_exited(body):
	if body.name == "Player":
		target = null
		animated_sprite_2d.play("idle")
