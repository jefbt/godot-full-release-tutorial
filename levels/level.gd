# Represents a game level. Manages collectibles, orbs, and level completion logic.
class_name Level extends Node2D

# Level identifier
@export var level_index: int = 0

# Collectible completion indicators
@onready var target_a_collected: Sprite2D = $Collectibles/TargetA/TargetACollected
@onready var target_b_collected: Sprite2D = $Collectibles/TargetB/TargetBCollected
@onready var target_c_collected: Sprite2D = $Collectibles/TargetC/TargetCCollected
@onready var finish_level: FinishLevel = $Collectibles/FinishLevel
# Container for all orbs in the level
@onready var orbs: Node2D = $Orbs

# Total number of orbs in this level
var max_orbs: int = 0

# Initialize level - hide collectible indicators and count orbs
func _ready() -> void:
	target_a_collected.visible = false
	target_b_collected.visible = false
	target_c_collected.visible = false
	max_orbs = orbs.get_child_count()
	GameManager.set_level(self)

# Called when all collectibles are gathered - enable level finish
func on_get_all_collectibles() -> void:
	finish_level.on_get_all_collectibles()

# Update UI when a collectible is gathered
func on_collected(collectible: Collectible) -> void:
	match(collectible.type):
		Collectible.Type.A:
			target_a_collected.visible = true
		Collectible.Type.B:
			target_b_collected.visible = true
		Collectible.Type.C:
			target_c_collected.visible = true
