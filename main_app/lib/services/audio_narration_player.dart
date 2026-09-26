import 'dart:io';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Audited Audio Narration Player service handling ElevenLabs audio file downloading,
/// local caching, audio context configuration, volume setting, and playback auditing.
class AudioNarrationPlayer {
  final AudioPlayer _player = AudioPlayer();

  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<Duration>? _positionSub;

  PlayerState _state = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  PlayerState get state => _state;
  Duration get duration => _duration;
  Duration get position => _position;
  bool get isPlaying => _state == PlayerState.playing;

  final void Function(PlayerState state)? onStateChanged;
  final void Function(Duration position)? onPositionChanged;
  final void Function(Duration duration)? onDurationChanged;

  AudioNarrationPlayer({
    this.onStateChanged,
    this.onPositionChanged,
    this.onDurationChanged,
  }) {
    _initListeners();
  }

  void _initListeners() {
    _stateSub = _player.onPlayerStateChanged.listen((s) {
      _state = s;
      debugPrint('🔊 [AudioPlayer Audit]: Player state changed to: $s');
      onStateChanged?.call(s);
    });

    _durationSub = _player.onDurationChanged.listen((d) {
      _duration = d;
      debugPrint('🔊 [AudioPlayer Audit]: Audio duration loaded: ${d.inSeconds}s (${d.inMilliseconds}ms)');
      onDurationChanged?.call(d);
    });

    _positionSub = _player.onPositionChanged.listen((p) {
      _position = p;
      onPositionChanged?.call(p);
    });
  }

  /// Downloads ElevenLabs narration MP3 from backend and starts playback with explicit volume and audio context.
  Future<bool> playUrl(String url, {String? cacheKey}) async {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🔊 [AudioPlayer Audit Step 1]: Requesting playback for URL: $url');

    try {
      await _player.stop();

      // Configure Audio Context & Volume for uninhibited playback
      try {
        await _player.setAudioContext(
          AudioContext(
            android: const AudioContextAndroid(
              contentType: AndroidContentType.music,
              usageType: AndroidUsageType.media,
              audioFocus: AndroidAudioFocus.gainTransientMayDuck,
            ),
            iOS: AudioContextIOS(
              category: AVAudioSessionCategory.playback,
              options: const {AVAudioSessionOptions.mixWithOthers},
            ),
          ),
        );
      } catch (ctxError) {
        debugPrint('⚠️ [AudioPlayer Audit Warning]: AudioContext config failed: $ctxError');
      }

      await _player.setVolume(1.0);
      debugPrint('🔊 [AudioPlayer Audit Step 2]: Set volume to 1.0 (100%)');

      // Step 8: Write audio to a local temporary file for 100% reliable cross-platform playback
      final file = await _downloadOrGetLocalFile(url, cacheKey);
      debugPrint('🔊 [AudioPlayer Audit Step 3]: Local MP3 File Ready: ${file.path} (${await file.length()} bytes)');

      // Step 9: Pass DeviceFileSource to AudioPlayer
      debugPrint('🔊 [AudioPlayer Audit Step 4]: Passing DeviceFileSource to player.play()');
      await _player.play(DeviceFileSource(file.path));

      // Step 10: Playback start confirmation
      debugPrint('✅ [AudioPlayer Audit Step 5]: Playback command dispatched successfully!');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return true;
    } catch (e, stackTrace) {
      // Step 11: Log exact exception and stack trace
      debugPrint('❌ [AudioPlayer Audit EXCEPTION]: Playback failed!');
      debugPrint('❌ Exception details: $e');
      debugPrint('❌ Stack trace:\n$stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return false;
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      debugPrint('❌ Error pausing player: $e');
    }
  }

  Future<void> resume() async {
    try {
      await _player.resume();
    } catch (e) {
      debugPrint('❌ Error resuming player: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('❌ Error stopping player: $e');
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      debugPrint('❌ Error seeking player: $e');
    }
  }

  void dispose() {
    _stateSub?.cancel();
    _durationSub?.cancel();
    _positionSub?.cancel();
    _player.stop();
    _player.dispose();
  }

  /// Downloads MP3 from backend URL to local temp directory and caches file.
  Future<File> _downloadOrGetLocalFile(String url, String? key) async {
    final tempDir = await getTemporaryDirectory();
    final safeKey = (key != null && key.isNotEmpty) ? key : url.hashCode.toString();
    final file = File('${tempDir.path}${Platform.pathSeparator}elevenlabs_narration_$safeKey.mp3');

    if (await file.exists() && await file.length() > 2048) {
      debugPrint('📦 [AudioPlayer Audit]: Reusing cached local audio file: ${file.path}');
      return file;
    }

    debugPrint('🌐 [AudioPlayer Audit]: Downloading audio bytes from backend: $url');
    final response = await http.get(Uri.parse(url));

    debugPrint('🌐 [AudioPlayer Audit]: Backend HTTP Download Response Status: ${response.statusCode}');
    if (response.statusCode != 200) {
      throw StateError('Failed to download audio from backend. HTTP Status: ${response.statusCode}');
    }

    final bytes = response.bodyBytes;
    if (bytes.isEmpty) {
      throw StateError('Backend returned 0 audio bytes!');
    }

    await file.writeAsBytes(bytes, flush: true);
    debugPrint('💾 [AudioPlayer Audit]: Saved ${bytes.length} bytes to ${file.path}');
    return file;
  }
}
