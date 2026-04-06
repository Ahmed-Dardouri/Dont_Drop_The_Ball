class_name AugmentData extends Resource
## Defines a single augment that can modify gameplay.

## Unique identifier for this augment
@export var augment_id: String = ""

## Display name shown in UI
@export var display_name: String = ""

## Description shown in UI
@export_multiline var description: String = ""

## Icon class/family for card visual (score, burst, line, vortex, life, spawn, meter, slowdown, orb, ball)
@export var icon_key: String = ""

## Key used to apply the augment effect
@export var augment_key: String = ""

## Rarity of this augment (determines card background)
@export var rarity: int = Enums.AugmentRarity.COMMON

## Selection mode: UNIQUE = one per run, REPEATABLE = can stack
@export var selection_mode: int = Enums.AugmentSelectionMode.UNIQUE

## Phase weight controls availability (0 = cannot appear in that phase)
@export var early_weight: int = 0
@export var mid_weight: int = 0
@export var late_weight: int = 0


## Returns true if this augment data is valid for use
func is_valid() -> bool:
	return augment_id != "" and display_name != "" and icon_key != "" and augment_key != ""
