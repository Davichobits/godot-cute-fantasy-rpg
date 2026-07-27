extends CharacterBody2D

const SPEED = 300.0

var is_attacking: bool = false
var last_direction: Vector2 = Vector2.RIGHT
# Vector2.RIGHT -> (1, 0)
# Vector2.LEFT  -> (-1, 0)
# Vector2.UP    -> (0, -1)
# Vector2.DOWN  -> (0, 1)
# Vector2.ZERO  -> (0, 0)
# Vector2.ONE   -> (1, 1)

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
# @onready -> wait until the node has been entered on scene

func _physics_process(_delta: float) -> void:
	
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
	play_animation("attack", last_direction)


func _on_animated_sprite_2d_animation_finished() -> void:
	if is_attacking:
		is_attacking = false
