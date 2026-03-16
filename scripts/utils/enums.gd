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
	BALL_RESCUE
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

enum OrbRarity {
	COMMON,
	UNCOMMON,
	RARE
}
