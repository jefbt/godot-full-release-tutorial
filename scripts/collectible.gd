# Collectible item (A, B, or C) required to complete a level.
# Shows appropriate visual and notifies game manager when collected.
class_name Collectible extends Area2D

@onready var animated_sprite_a: AnimatedSprite2D = $AnimatedSpriteA
@onready var animated_sprite_b: AnimatedSprite2D = $AnimatedSpriteB
@onready var animated_sprite_c: AnimatedSprite2D = $AnimatedSpriteC

# Collectible types
enum Type { A, B, C }
@export var type: Type = Type.A

# Set up visual based on collectible type
func _ready() -> void:
	match(type):
		Type.A:
			animated_sprite_a.visible = true
			animated_sprite_b.visible = false
			animated_sprite_c.visible = false
		Type.B:
			animated_sprite_a.visible = false
			animated_sprite_b.visible = true
			animated_sprite_c.visible = false
		Type.C:
			animated_sprite_a.visible = false
			animated_sprite_b.visible = false
			animated_sprite_c.visible = true

# Handle player collecting this item
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		GameManager.collect(self)
