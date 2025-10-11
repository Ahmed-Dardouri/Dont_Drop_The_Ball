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
	LOFI_BG_MUSIC
}

enum MainButtonType {
	PLAY,
	SETTINGS,
	BACK,
	EXIT,
}

enum MainScene {
	WORLD_BUILDER,
	MAIN_MENU,
	SETTINGS_MENU,
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
