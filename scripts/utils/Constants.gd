extends Node

#region player_constants

var player_keyboard_move_power : int = 500
var player_jump_power : int = -700
var player_initial_move_speed : int = 300
var player_coyote_timeout : float = 150.0
var player_jump_buffer_timeout : float = 150.0
var player_grounding_force : float = 1.5
var player_fall_acceleration : float = 1800.0
var player_max_fall_speed : float = 800
var player_Jump_ended_early_gravity_modifier : float = 3.0
var player_move_acceleration : float = 1000
var player_initial_move_acceleration : float = 5000
var player_move_deceleration : float = 10000
var player_stop_on_ceiled : bool = false
var player_mass_const : float = 100.0
var player_gravity : float = 1.0

#endregion

#region ball_constants

var ball_max_speed := 900.0
var ball_fall_speed := 500.0
var ball_air_friction := 9

#endregion

#region orb_constants

var orb_lifespan_blue = 30
var orb_lifespan_red = 30
var orb_lifespan_half_solid = 40

var orb_score_blue = 2
var orb_score_red = 3
var orb_score_half_solid = 8

#endregion
