/// AudioManager service for controlling sound effects (SFX) and background music (BGM).
class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool isMuted = false;

  /// Plays a sound effect.
  void playSfx(String sfxPath) {
    if (isMuted) return;
    // SFX playback handler
  }

  /// Plays background music.
  void playBgm(String bgmPath) {
    if (isMuted) return;
    // BGM playback handler
  }
}
