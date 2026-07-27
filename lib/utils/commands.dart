class ScoreboardCommands {
  static const start = 'START';
  static const end = 'END';
  static const reset = 'RESET';
  static const aPlus = 'A+';
  static const aMinus = 'A-';
  static const bPlus = 'B+';
  static const bMinus = 'B-';
  static const play = 'PLAY';
  static const pause = 'PAUSE';
  static const next = 'NEXT';
  static const prev = 'PREV';
  static const volUp = 'VOLUP';
  static const volDown = 'VOLDOWN';
  static const mute = 'MUTE';
  static const unmute = 'UNMUTE';
  static const repeat = 'REPEAT';
  static const shuffle = 'SHUFFLE';
  static const audio = 'AUDIO';

  static String nameA(String name) => 'NAMEA:$name';
  static String nameB(String name) => 'NAMEB:$name';
  static String playTrack(int n) => 'PLAYTRACK:$n';
  static String wire(String command) => '$command\n';
}
