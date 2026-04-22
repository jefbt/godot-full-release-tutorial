class_name Level extends Node2D

@export var level_index: int = 0

@onready var target_a_collected: Sprite2D = $Collectibles/TargetA/TargetACollected
@onready var target_b_collected: Sprite2D = $Collectibles/TargetB/TargetBCollected
@onready var target_c_collected: Sprite2D = $Collectibles/TargetC/TargetCCollected
@onready var finish_level: FinishLevel = $Collectibles/FinishLevel
@onready var orbs: Node2D = $Orbs

var max_orbs: int = 0

func _ready() -> void:
	target_a_collected.visible = false
	target_b_collected.visible = false
	target_c_collected.visible = false
	GameManager.set_level(self)
	max_orbs = orbs.get_child_count()

func on_get_all_collectibles() -> void:
	finish_level.on_get_all_collectibles()

func on_collected(collectible: Collectible) -> void:
	match(collectible.type):
		Collectible.Type.A:
			target_a_collected.visible = true
		Collectible.Type.B:
			target_b_collected.visible = true
		Collectible.Type.C:
			target_c_collected.visible = true
