extends CanvasLayer

const HEART_SIZE = 20
const HEART_FULL =  preload("res://assets/images/UI/Heart_full.png")
const HEART_HALF =  preload("res://assets/images/UI/Heart_half.png")
const HEART_EMPTY =  preload("res://assets/images/UI/Heart_empty.png")
var player

@onready var fade_overlay: ColorRect = $FadeOverlay
@onready var hearts_container:HBoxContainer = $Hearts


func set_player(_player) -> void:
	player = _player
	if player:
		player.health_changed.connect(_update_health)
		_update_health(player.health)
	
func _update_health(new_health: int) -> void:
	var hearts = hearts_container.get_children()
	var max_hearts = len(hearts)
	var full: int = int(new_health / HEART_SIZE)
	var half: int = 1 if (new_health % HEART_SIZE) > 0 else 0
	var empty:int = max_hearts - (full + half)
	
	# update full hearts
	for i in full:
		hearts[i].texture = HEART_FULL
	if half:
		hearts[full].texture = HEART_HALF
	for i in empty:
		hearts[len(hearts) - 1 - i].texture = HEART_EMPTY

func fade(to_alpha: float) -> void:
	var tween:= create_tween()
	tween.tween_property(fade_overlay, "modulate:a", to_alpha, 1.5)
	await tween.finished
