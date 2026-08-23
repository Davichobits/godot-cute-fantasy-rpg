extends CharacterBody2D

const SPEED = 300.0

signal died
signal health_changed(new_health: int)

var is_attacking: bool = false
var hitbox_offset: Vector2
var last_direction: Vector2 = Vector2.RIGHT
# Vector2.RIGHT -> (1, 0)
# Vector2.LEFT  -> (-1, 0)
# Vector2.UP    -> (0, -1)
# Vector2.DOWN  -> (0, 1)
# Vector2.ZERO  -> (0, 0)
# Vector2.ONE   -> (1, 1)
var strength: int = 20
var health: int
var max_health: int
var is_alive: bool = true

# @onready -> wait until the node has been entered on scene
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var take_damage_sound: AudioStreamPlayer2D = $TakeDamage
@onready var swing_sword_sound: AudioStreamPlayer2D = $SwingSword
@onready var dying_sound: AudioStreamPlayer2D = $Dying
@onready var damage_cooldown: Timer = $DamageCooldown
@onready var hitbox: Area2D = $Hitbox

func _ready() -> void:
	health = PlayerStats.health
	max_health = PlayerStats.max_health
	# initialise hitbox offset
	hitbox_offset = hitbox.position

func _physics_process(_delta: float) -> void:
	# Disable hitbox until an attack is trigered
	hitbox.monitoring = false
	if is_alive:
		if Input.is_action_just_pressed("attack") and not is_attacking:
			attack()
			
		# skip movement if attacking
		if is_attacking:
			velocity = Vector2.ZERO
			return
		
		process_movement()
		process_animation()
		move_and_slide()

func process_movement() -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		last_direction = direction
		update_hitbox_offset()
	else:
		velocity = Vector2.ZERO
	
func process_animation() -> void:
	if is_attacking:
		return
	if velocity != Vector2.ZERO:
		play_animation("run", last_direction)
	else:
		play_animation("idle", last_direction)

func play_animation(prefix: String, dir: Vector2) -> void:
	if dir.x != 0:
		animated_sprite_2d.flip_h = dir.x < 0
		animated_sprite_2d.play(prefix + "_right")
	elif dir.y < 0:
		animated_sprite_2d.play(prefix + "_up")
	elif dir.y > 0:
		animated_sprite_2d.play(prefix + "_down")

func attack() -> void:
	is_attacking = true
	hitbox.monitoring = true
	swing_sword_sound.play()
	play_animation("attack", last_direction)

func _on_animated_sprite_2d_animation_finished() -> void:
	if is_attacking:
		is_attacking = false

func update_hitbox_offset() -> void:
	var x:= hitbox_offset.x
	var y:= hitbox_offset.y
	
	match last_direction:
		Vector2.LEFT:
			hitbox.position = Vector2(-x, y)
		Vector2.RIGHT:
			hitbox.position = Vector2(x, y)
		Vector2.UP:
			hitbox.position = Vector2(y, -x)
		Vector2.DOWN:
			hitbox.position = Vector2(y, x)

func _on_hitbox_body_entered(body):
	if is_attacking and body.name.begins_with("Slime"):
		body.take_damage(strength, position)
		print(body.health)
		
func heal(amount: int) -> void:
	health += amount
	if health >= max_health:
		health = max_health
	PlayerStats.health = health
	emit_signal("health_changed", health)

func take_damage(amount: int) -> void:
	if not is_alive:
		return
	if damage_cooldown.time_left > 0:
		return
		
	health -= amount
	# health_changed.emit(health)
	emit_signal("health_changed", health)
	
	if health <= 0:
		die()
	else:
		PlayerStats.health = health
		take_damage_sound.play()
		# Make player invincible for a short time
		damage_cooldown.start()

func die() -> void:
	animated_sprite_2d.play("dying")
	dying_sound.play()
	is_alive = false
	await animated_sprite_2d.animation_finished
	died.emit()
