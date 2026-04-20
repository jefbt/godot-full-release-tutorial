class_name Collectible extends Area2D

@onready var animated_sprite_a: AnimatedSprite2D = $AnimatedSpriteA
@onready var animated_sprite_b: AnimatedSprite2D = $AnimatedSpriteB
@onready var animated_sprite_c: AnimatedSprite2D = $AnimatedSpriteC

enum Type { A, B, C }
@export var type: Type = Type.A

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

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		GameManager.collect(self)
