class_name AugmentData extends Resource
## Defines a single augment that can modify gameplay.
## Phase 1: Simple data structure for prototype augments.

## Unique identifier for this augment
@export var augment_id: String = ""

## Display name shown in UI
@export var display_name: String = ""

## Description shown in UI
@export_multiline var description: String = ""

## Icon texture for the card (placeholder OK)
@export var icon: Texture2D = null

## Type of effect this augment applies
@export var effect_type: int = 0  # Enums.AugmentEffect

## Numeric value for the effect (meaning depends on effect_type)
@export var effect_value: float = 1.0

## Whether this augment can stack if selected multiple times
@export var can_stack: bool = true

## Maximum stacks allowed (only relevant if can_stack is true)
@export var max_stacks: int = 10


## Returns true if this augment data is valid for use
func is_valid() -> bool:
	return augment_id != "" and display_name != ""
