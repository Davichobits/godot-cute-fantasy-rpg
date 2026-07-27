extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D

const SPEED = 300.0

func _physics_process(delta):
	process_movement()
	move_and_slide()

func process_movement() -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_vector("left", "right", "up", "down")
	
	velocity = direction * SPEED
	play_animation(direction)
	
func play_animation(dir: Vector2) -> void:
	if dir.x > 0:
		animated_sprite_2d.play("idle_right")
