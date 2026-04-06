class_name Enums extends Node

enum PlayerMoves {
	JUMP,
	RIGHT,
	LEFT
}

enum OrbType {
	RED,
	BLUE,
	HALF_SOLID
}

enum SoundType {
	MUSIC,
	SFX
}

enum SoundCmd {
	PLAY,
	STOP,
	PAUSE,
	RESUME
}

enum Sounds {
	ORB_COLLECTED,
	GAME_OVER,
	LOFI_BG_MUSIC,
	BALL_RESCUE,
	CARD_SELECT
}

enum MainButtonType {
	PLAY,
	SETTINGS,
	BACK,
	EXIT,
	MODE_SELECT,
}

enum MainScene {
	WORLD_BUILDER,
	MAIN_MENU,
	SETTINGS_MENU,
	MODE_SELECT_MENU,
	TUTORIAL
}

enum WorldScene {
	GAME,
	PAUSE_SCREEN,
	GAME_OVER_SCREEN
}

enum WorldButtonType {
	MAIN_MENU,
	BACK,
	REPLAY
}

enum GameMode {
	MENU,
	PLAYING,
	PAUSED,
	GAME_OVER
}

enum AugmentRarity {
	COMMON,
	RARE,
	MYTHICAL
}

## Game phases for augment availability
enum GamePhase {
	EARLY,
	MID,
	LATE
}

## Augment selection mode: UNIQUE = one per run, REPEATABLE = can stack
enum AugmentSelectionMode {
	UNIQUE,
	REPEATABLE
}

## Types of augment effects for Phase 1 prototype
enum AugmentEffect {
	FLAT_SCORE_BONUS,        ## +X score per orb collected
	SPAWN_RATE_MULTIPLIER,   ## Orb spawn rate multiplied by X
	BURST_RADIUS_MULTIPLIER, ## Burst orb radius multiplied by X
	LINE_CLEAR_RANGE_MULT,   ## Line clear range multiplied by X
	VORTEX_RADIUS_MULT,      ## Vortex radius multiplied by X
	MAX_LIVES_BONUS,         ## +X max lives
	METER_FILL_MULT,         ## Bonus meter fill rate multiplied by X
	BALL_SLOWDOWN_MULT       ## Ball slowdown strength multiplied by X
}
