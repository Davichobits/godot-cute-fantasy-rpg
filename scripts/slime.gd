extends CharacterBody2D

const SPEED: int = 100
const KNOCKBACK_FORCE: int = 100
const DROP_CHANCE: float = 0.5

var is_alive: bool = true
var target = null
var target_in_range: bool = false
var health: int = 100
var strength: int = 10 

var health_pickup_scene = preload("res://scenes/heallth_pickup.tscn")

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var take_damage_sound = $TakeDamage
@onready var health_bar = $HealthBar
@onready var attack_timer = $Attack_Timer

func _physics_process(delta):
	if is_alive and target:
		_attack(delta)
	
func _attack(delta: float) -> void:
	var direction = (target.position - position).normalized()
	position += direction * SPEED * delta
	animated_sprite_2d.play("attack")

func take_damage(damage: int, attaker_position: Vector2) -> void:
	health -= damage
	take_damage_sound.play()
	# knockback
	var knockback_direction = (position - attaker_position).normalized()
	var target_position = position + knockback_direction * KNOCKBACK_FORCE
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position", target_position, 0.5)
	health_bar.update_health(health)
	if health <= 0:
		die()
	
func die() -> void:
	is_alive = false
	animated_sprite_2d.play("die")
	take_damage_sound.pitch_scale = 0.5
	take_damage_sound.play()
	
	# Disable collision
	$CollisionShape2D.set_deferred("disabled", true)
	$Sight/CollisionShape2D.set_deferred("disabled", true)
	
	# drop health pickup
	if randf() <= DROP_CHANCE:
		drop_item()

func _on_sight_body_entered(body):
	if body.name == "Player":
		target = body

func _on_sight_body_exited(body):
	if body.name == "Player":
		target = null
		if is_alive:
			animated_sprite_2d.play("idle")

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Player" and is_alive:
		target_in_range = true
		body.take_damage(strength)
		attack_timer.start()

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		target_in_range = false
		attack_timer.stop()

func _on_attack_timer_timeout():
	if target and target_in_range:
		target.take_damage(strength)
		
func drop_item():
	var drop = health_pickup_scene.instantiate()
	drop.position = position
	var level_root = get_parent().get_parent()
	var items_node = level_root.get_node("Items")
	items_node.call_deferred("add_child", drop)
