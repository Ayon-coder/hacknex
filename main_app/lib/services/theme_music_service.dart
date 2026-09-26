import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
/// Background score for the intro screens.
///
/// Prefers a real recording at [_assetPath]; drop an mp3 there and it is used
/// verbatim. With no asset present it synthesizes an original celesta waltz so
/// the cinematic is never silent. Either way the track loops quietly under the
/// narration and is ducked while the voice speaks.
class ThemeMusicService {
  ThemeMusicService._();

  static final ThemeMusicService instance = ThemeMusicService._();

  static const String _assetPath = 'assets/audio/hedwigs_theme.mp3';

  /// Cloudinary delivers just the audio track when the extension is changed
  /// from .mp4 → .mp3. The video data is never transferred — Cloudinary
  /// transcodes on-the-fly at the CDN edge, so this works on any device
  /// without bundling a large file inside the APK.
  static const String _cloudinaryAudioUrl =
      'https://res.cloudinary.com/drdflfgwi/video/upload/'
      'v1785028007/Hedwig_s_Theme_-_John_Williams_720p_h264_qevt12.mp3';

  /// Sits under narration without competing with it.
  static const double _fullVolume = 0.42;
  static const double _duckedVolume = 0.16;

  final AudioPlayer _player = AudioPlayer();

  bool _starting = false;
  bool _playing = false;
  double _target = _fullVolume;
  Timer? _fadeTimer;
  final List<StreamSubscription<void>> _subs = [];

  /// Last failure reported by the native side, for diagnostics.
  String? lastError;

  bool get isPlaying => _playing;

  /// Begins the loop. Safe to call from several screens; only the first starts
  /// playback, later calls just keep the existing loop running.
  Future<void> start() async {
    if (_playing || _starting) return;
    _starting = true;
    try {
      // Native failures arrive asynchronously on these streams rather than as
      // thrown exceptions, so without them a broken source fails silently.
      _subs.add(_player.onLog.listen(
        (msg) => debugPrint('ThemeMusic[native]: $msg'),
        onError: (Object e) {
          lastError = e.toString();
          debugPrint('ThemeMusic[native error]: $e');
        },
      ));
      _subs.add(_player.eventStream.listen(
        (_) {},
        onError: (Object e) {
          lastError = e.toString();
          debugPrint('ThemeMusic[event error]: $e');
        },
      ));

      // Try each source in priority order: Cloudinary CDN → bundled asset →
      // synthesized waltz. The first one that loads wins.
      final sources = await _buildSources();
      bool started = false;

      for (final entry in sources) {
        try {
          debugPrint('ThemeMusic: trying ${entry.label}');
          await _player.setSource(entry.source);
          await _player.setReleaseMode(ReleaseMode.loop);

          // Windows logs "not supported" for this and ignores it; mobile needs
          // it so the score mixes with narration instead of stealing focus.
          if (!kIsWeb &&
              (defaultTargetPlatform == TargetPlatform.android ||
                  defaultTargetPlatform == TargetPlatform.iOS)) {
            await _player.setAudioContext(
              AudioContext(
                android: const AudioContextAndroid(
                  contentType: AndroidContentType.music,
                  usageType: AndroidUsageType.media,
                  audioFocus: AndroidAudioFocus.none,
                ),
                iOS: AudioContextIOS(
                  category: AVAudioSessionCategory.ambient,
                  options: const {AVAudioSessionOptions.mixWithOthers},
                ),
              ),
            );
          }

          await _player.setVolume(0);
          await _player.resume();
          _playing = true;
          _fadeTo(_target, const Duration(milliseconds: 2200));
          debugPrint('ThemeMusic: playing ${entry.label}, fading to $_target');
          started = true;
          break;
        } catch (e) {
          lastError = e.toString();
          debugPrint('ThemeMusic: ${entry.label} failed: $e — trying next source');
        }
      }

      if (!started) {
        debugPrint('ThemeMusic: all sources exhausted, running silent');
      }
    } catch (e, stack) {
      lastError = e.toString();
      debugPrint('ThemeMusic: start failed: $e\n$stack');
      _playing = false;
    } finally {
      _starting = false;
    }
  }

  /// Drops the score under spoken narration.
  void duck() => _setTarget(_duckedVolume, const Duration(milliseconds: 900));

  /// Lifts the score back once narration ends.
  void unduck() => _setTarget(_fullVolume, const Duration(milliseconds: 1600));

  Future<void> fadeOutAndStop(
      {Duration duration = const Duration(milliseconds: 1200)}) async {
    if (!_playing) return;
    _fadeTo(0, duration);
    await Future<void>.delayed(duration);
    await stop();
  }

  Future<void> stop() async {
    _fadeTimer?.cancel();
    _fadeTimer = null;
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
    if (!_playing) return;
    _playing = false;
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('ThemeMusic: stop failed: $e');
    }
  }

  void _setTarget(double volume, Duration duration) {
    _target = volume;
    if (_playing) _fadeTo(volume, duration);
  }

  /// Ramps volume in steps — audioplayers has no native fade.
  void _fadeTo(double to, Duration duration) {
    _fadeTimer?.cancel();
    const step = Duration(milliseconds: 60);
    final steps = math.max(1, duration.inMilliseconds ~/ step.inMilliseconds);
    final from = _player.volume;
    var i = 0;

    _fadeTimer = Timer.periodic(step, (timer) {
      i++;
      final t = (i / steps).clamp(0.0, 1.0);
      final value = from + (to - from) * t;
      _player.setVolume(value).catchError((Object _) {});
      if (t >= 1.0) timer.cancel();
    });
  }

  /// Returns sources to try in priority order.
  Future<List<_SourceEntry>> _buildSources() async {
    final sources = <_SourceEntry>[];

    // 1. Cloudinary CDN — audio-only stream extracted from the uploaded MP4.
    //    Works on any device with internet; nothing is bundled in the APK.
    sources.add(_SourceEntry(
      label: 'Cloudinary stream',
      source: UrlSource(_cloudinaryAudioUrl),
    ));

    // 2. Bundled asset — works offline if the mp3 is present in assets/audio/.
    try {
      await rootBundle.load(_assetPath);
      sources.add(_SourceEntry(
        label: 'bundled asset ($_assetPath)',
        source: AssetSource(_assetPath.replaceFirst('assets/', '')),
      ));
    } catch (_) {
      debugPrint('ThemeMusic: bundled asset not found, skipping');
    }

    // 3. Synthesized waltz — always works, no network or bundled file needed.
    try {
      final file = await _synthesizedFile();
      sources.add(_SourceEntry(
        label: 'synthesized waltz (${file.path})',
        source: DeviceFileSource(file.path),
      ));
    } catch (e) {
      debugPrint('ThemeMusic: synthesis failed: $e');
    }

    return sources;
  }

  /// Renders the waltz once and caches the wav, so later launches skip the
  /// (several hundred millisecond) synthesis entirely.
  Future<File> _synthesizedFile() async {
    final directory = await getApplicationSupportDirectory();
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    final file = File(
      '${directory.path}${Platform.pathSeparator}theme_waltz_$_sampleRate.wav',
    );
    if (await file.exists() && await file.length() > 1024) return file;

    final bytes = await compute(renderThemeWav, _sampleRate);
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  /// 44.1 kHz: Media Foundation on Windows is unreliable with less common
  /// sample rates, and every platform handles CD rate without complaint.
  static const int _sampleRate = 44100;

  Future<void> dispose() async {
    _fadeTimer?.cancel();
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
    await _player.dispose();
  }
}

/// Pairs an audioplayers [Source] with a human-readable label for logging.
class _SourceEntry {
  const _SourceEntry({required this.label, required this.source});
  final String label;
  final Source source;
}

// ─────────────────────────────────────────────────────────────────────────────
// Synthesis
//
// An original minor-key celesta waltz — bell-like partials with a fast decay
// over a soft harp accompaniment, run through a small reverb so it sounds like
// a hall rather than a ringtone. Runs in an isolate via compute().
// ─────────────────────────────────────────────────────────────────────────────

/// One struck note: MIDI pitch, start beat, length in beats, loudness.
class _Note {
  const _Note(this.midi, this.beat, this.beats, this.gain);
  final int midi;
  final double beat;
  final double beats;
  final double gain;
}

const double _bpm = 132;

/// 16 bars of 3/4.
const double _totalBeats = 48.0;

/// Extra render time so the closing chord's decay can be folded back over the
/// opening instead of being chopped at the loop point.
const double _tailSeconds = 1.6;

/// Melody in E minor, 3/4 — a wistful theme that lifts an octave at the
/// halfway point and settles back down.
const List<List<num>> _melodyRaw = [
  // [midi, beat, beats]
  [71, 0, 1], [76, 1, 1], [79, 2, 1], // Em rise
  [78, 3, 2], [76, 5, 1],
  [83, 6, 1], [81, 7, 2],
  [78, 9, 3],

  [76, 12, 1], [79, 13, 1], [81, 14, 1],
  [79, 15, 2], [76, 17, 1],
  [75, 18, 3], // D# over B7 — the leading tone that pulls back to Em
  // bar 8 rests

  [83, 24, 1], [88, 25, 1], [91, 26, 1], // octave up
  [90, 27, 2], [88, 29, 1],
  [95, 30, 1], [93, 31, 2],
  [90, 33, 3],

  [88, 36, 1], [91, 37, 1], [93, 38, 1],
  [91, 39, 2], [88, 41, 1],
  [88, 42, 3], // resolve
  // bar 16 rests into the loop
];

/// Root note per two-bar span, and the triad voiced above it.
const List<List<num>> _harmonyRaw = [
  // [rootMidi, chordA, chordB, chordC, startBeat]
  [40, 52, 55, 59, 0], // Em
  [35, 54, 59, 62, 6], // Bm
  [36, 55, 60, 64, 12], // C
  [35, 51, 54, 57, 18], // B7
  [40, 52, 55, 59, 24], // Em
  [35, 54, 59, 62, 30], // Bm
  [36, 55, 60, 64, 36], // C
  [40, 52, 55, 59, 42], // Em
];

/// Renders the score to a 16-bit mono WAV. Top-level so it can run in an
/// isolate; [sampleRate] is the only input.
Uint8List renderThemeWav(int sampleRate) {
  const secondsPerBeat = 60.0 / _bpm;
  final loopSamples = (_totalBeats * secondsPerBeat * sampleRate).round();
  final tailSamples = (_tailSeconds * sampleRate).round();
  final buffer = Float64List(loopSamples + tailSamples);

  for (final raw in _melodyRaw) {
    _renderCelesta(
      buffer,
      sampleRate,
      _Note(raw[0].toInt(), raw[1].toDouble(), raw[2].toDouble(), 0.85),
      secondsPerBeat,
    );
  }

  for (final chord in _harmonyRaw) {
    final root = chord[0].toInt();
    final startBeat = chord[4].toDouble();

    // Waltz figure: bass on 1, chord tones on 2 and 3, twice per span.
    for (var bar = 0; bar < 2; bar++) {
      final barStart = startBeat + bar * 3;
      _renderHarp(
        buffer,
        sampleRate,
        _Note(root, barStart, 2.6, 0.34),
        secondsPerBeat,
      );
      for (var beat = 1; beat <= 2; beat++) {
        for (var v = 1; v <= 3; v++) {
          _renderHarp(
            buffer,
            sampleRate,
            _Note(chord[v].toInt(), barStart + beat, 1.1, 0.10),
            secondsPerBeat,
          );
        }
      }
    }
  }

  _applyReverb(buffer, sampleRate);

  // Fold the ring-out back over the opening so the final chord decays into the
  // next repetition — this is what makes the loop point inaudible.
  final loop = Float64List(loopSamples);
  for (var i = 0; i < loopSamples; i++) {
    loop[i] = buffer[i];
  }
  for (var i = 0; i < tailSamples && i < loopSamples; i++) {
    loop[i] += buffer[loopSamples + i];
  }

  _normalize(loop, 0.72);
  return _encodeWav(loop, sampleRate);
}

double _freq(int midi) => 440.0 * math.pow(2, (midi - 69) / 12.0);

/// Celesta: bright inharmonic partials over a fast exponential decay.
void _renderCelesta(
  Float64List out,
  int sampleRate,
  _Note note,
  double secondsPerBeat,
) {
  final start = (note.beat * secondsPerBeat * sampleRate).round();
  final held = note.beats * secondsPerBeat;
  // Let the bell ring past its written length rather than cutting it off.
  final duration = held + 1.4;
  final length = (duration * sampleRate).round();
  final f = _freq(note.midi);

  // Slightly stretched partials are what make a struck bar read as metallic
  // rather than as a plain organ tone.
  const partials = <List<double>>[
    [1.0, 1.00, 1.00],
    [2.0, 0.42, 1.70],
    [3.01, 0.20, 2.60],
    [4.98, 0.11, 3.40],
    [6.94, 0.05, 4.30],
  ];

  for (var i = 0; i < length; i++) {
    final index = start + i;
    if (index < 0) continue;
    if (index >= out.length) break;

    final t = i / sampleRate;
    // 6 ms strike, then decay.
    final attack = t < 0.006 ? t / 0.006 : 1.0;

    var sample = 0.0;
    for (final p in partials) {
      final decay = math.exp(-t * p[2] * 1.15);
      sample += p[1] * decay * math.sin(2 * math.pi * f * p[0] * t);
    }

    out[index] += sample * attack * note.gain * 0.22;
  }
}

/// Harp: soft, mostly-harmonic, slower decay. Carries the accompaniment.
void _renderHarp(
  Float64List out,
  int sampleRate,
  _Note note,
  double secondsPerBeat,
) {
  final start = (note.beat * secondsPerBeat * sampleRate).round();
  final duration = note.beats * secondsPerBeat + 0.9;
  final length = (duration * sampleRate).round();
  final f = _freq(note.midi);

  for (var i = 0; i < length; i++) {
    final index = start + i;
    if (index < 0) continue;
    if (index >= out.length) break;

    final t = i / sampleRate;
    final attack = t < 0.012 ? t / 0.012 : 1.0;
    final decay = math.exp(-t * 1.5);

    final sample = math.sin(2 * math.pi * f * t) +
        0.34 * math.exp(-t * 2.4) * math.sin(4 * math.pi * f * t) +
        0.14 * math.exp(-t * 3.2) * math.sin(6 * math.pi * f * t);

    out[index] += sample * attack * decay * note.gain * 0.22;
  }
}

/// Four comb delays plus a smear — enough to place the notes in a stone hall
/// without pulling in a real reverb dependency.
void _applyReverb(Float64List buffer, int sampleRate) {
  const delaysMs = [37.0, 53.0, 71.0, 97.0];
  const feedback = 0.34;
  const wet = 0.30;

  final wetBuffer = Float64List(buffer.length);

  for (final ms in delaysMs) {
    final delay = (ms / 1000.0 * sampleRate).round();
    if (delay <= 0 || delay >= buffer.length) continue;
    for (var i = delay; i < buffer.length; i++) {
      wetBuffer[i] += (buffer[i - delay] + wetBuffer[i - delay] * feedback) *
          feedback *
          0.5;
    }
  }

  for (var i = 0; i < buffer.length; i++) {
    buffer[i] = buffer[i] + wetBuffer[i] * wet;
  }
}

void _normalize(Float64List buffer, double peak) {
  var max = 0.0;
  for (final v in buffer) {
    final a = v.abs();
    if (a > max) max = a;
  }
  if (max < 1e-9) return;
  final scale = peak / max;
  for (var i = 0; i < buffer.length; i++) {
    buffer[i] *= scale;
  }
}

Uint8List _encodeWav(Float64List samples, int sampleRate) {
  const channels = 1;
  const bitsPerSample = 16;
  final dataBytes = samples.length * 2;
  final bytes = Uint8List(44 + dataBytes);
  final view = ByteData.view(bytes.buffer);

  void writeAscii(int offset, String value) {
    for (var i = 0; i < value.length; i++) {
      bytes[offset + i] = value.codeUnitAt(i);
    }
  }

  writeAscii(0, 'RIFF');
  view.setUint32(4, 36 + dataBytes, Endian.little);
  writeAscii(8, 'WAVE');
  writeAscii(12, 'fmt ');
  view.setUint32(16, 16, Endian.little); // PCM chunk size
  view.setUint16(20, 1, Endian.little); // PCM format
  view.setUint16(22, channels, Endian.little);
  view.setUint32(24, sampleRate, Endian.little);
  view.setUint32(28, sampleRate * channels * bitsPerSample ~/ 8, Endian.little);
  view.setUint16(32, channels * bitsPerSample ~/ 8, Endian.little);
  view.setUint16(34, bitsPerSample, Endian.little);
  writeAscii(36, 'data');
  view.setUint32(40, dataBytes, Endian.little);

  for (var i = 0; i < samples.length; i++) {
    final clamped = samples[i].clamp(-1.0, 1.0);
    view.setInt16(44 + i * 2, (clamped * 32767).round(), Endian.little);
  }

  return bytes;
}
