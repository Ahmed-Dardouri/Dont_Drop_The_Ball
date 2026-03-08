extends GutTest
## Unit tests for SavedGame resource class
## Tests the save data structure


func test_saved_game_default_values() -> void:
	var save := SavedGame.new()
	# Default int values in GDScript are 0
	assert_eq(save.pb, 0, "Default pb should be 0")
	assert_eq(save.Sfx_volume, 0, "Default Sfx_volume should be 0")
	assert_eq(save.Music_volume, 0, "Default Music_volume should be 0")


func test_saved_game_set_pb() -> void:
	var save := SavedGame.new()
	save.pb = 100
	assert_eq(save.pb, 100, "pb should be settable")


func test_saved_game_set_volumes() -> void:
	var save := SavedGame.new()
	save.Sfx_volume = 50
	save.Music_volume = 75
	assert_eq(save.Sfx_volume, 50, "Sfx_volume should be settable")
	assert_eq(save.Music_volume, 75, "Music_volume should be settable")


func test_saved_game_is_resource() -> void:
	var save := SavedGame.new()
	assert_true(save is Resource, "SavedGame should extend Resource")


func test_saved_game_can_be_duplicated() -> void:
	var original := SavedGame.new()
	original.pb = 500
	original.Sfx_volume = 30
	original.Music_volume = 60

	var copy := original.duplicate()
	assert_eq(copy.pb, 500, "Duplicated pb should match")
	assert_eq(copy.Sfx_volume, 30, "Duplicated Sfx_volume should match")
	assert_eq(copy.Music_volume, 60, "Duplicated Music_volume should match")


func test_saved_game_high_score_tracking() -> void:
	# Simulate high score progression
	var save := SavedGame.new()

	# First score
	save.pb = 10
	assert_eq(save.pb, 10, "First high score")

	# Beat the high score
	save.pb = 25
	assert_eq(save.pb, 25, "New high score")

	# Don't update on lower score (this logic would be in game_save_mngr)
	var new_score := 15
	if new_score > save.pb:
		save.pb = new_score
	assert_eq(save.pb, 25, "High score should not decrease")
