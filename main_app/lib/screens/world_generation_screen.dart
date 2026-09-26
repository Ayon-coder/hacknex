import 'dart:io';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../models/player_profile.dart';
import '../services/intro_service.dart';
import '../services/theme_music_service.dart';
import '../theme/hogwarts_theme.dart';
import 'world_archipelago_screen.dart';

/// Cinematic opening: Gemini narrates, ElevenLabs speaks, the castle rises.
///
/// The build animation is gated on narration arriving so the two stay in sync;
/// if audio is unavailable the subtitles carry the scene at a reading pace.
/// The theme music loops underneath throughout, ducked while the voice speaks.
class WorldGenerationScreen extends StatefulWidget {
  const WorldGenerationScreen({super.key, required this.profile});

  final PlayerProfile profile;

  @override
  State<WorldGenerationScreen> createState() => _WorldGenerationScreenState();
}

class _WorldGenerationScreenState extends State<WorldGenerationScreen>
    with TickerProviderStateMixin {
  late final AnimationController _buildController;
  late final AnimationController _cloudController;
  final AudioPlayer _player = AudioPlayer();

  final List<StreamSubscription<void>> _subs = [];
  Timer? _subtitleTimer;

  List<String> _lines = const [];
  int _lineIndex = 0;
  bool _ready = false;
  bool _finished = false;
  bool _audioPlaying = false;
  Duration? _audioDuration;
  String _status = 'The owls are gathering...';

  /// Ordered beats of the reveal, surfaced as [_buildController] advances.
  static const List<_Stage> _stages = [
    _Stage(0.00, 'Mist rolls off the Black Lake...'),
    _Stage(0.14, 'The cliffs rise from the water...'),
    _Stage(0.28, 'The Forbidden Forest takes root...'),
    _Stage(0.42, 'Stone towers climb the night...'),
    _Stage(0.56, 'The viaduct bridge is laid...'),
    _Stage(0.70, 'Candles light in every window...'),
    _Stage(0.84, 'Owls carry word of your arrival...'),
    _Stage(0.95, 'Hogwarts awaits you.'),
  ];

  @override
  void initState() {
    super.initState();
    _buildController = AnimationController(
      vsync: this,
      // Roughly the spoken length of a 120-word narration.
      duration: const Duration(seconds: 42),
    );
    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _buildController.addListener(_onBuildTick);
    ThemeMusicService.instance.start();
    _startSequence();
  }

  void _onBuildTick() {
    if (!mounted) return;
    final next = _stageFor(_buildController.value);
    if (next != _status) setState(() => _status = next);
  }

  String _stageFor(double t) {
    var label = _stages.first.label;
    for (final s in _stages) {
      if (t >= s.at) label = s.label;
    }
    return label;
  }

  Future<void> _startSequence() async {
    final result = await IntroService.fetchIntro(widget.profile);
    if (!mounted) return;

    setState(() {
      _lines = _splitIntoLines(result.narration);
      _ready = true;
    });

    if (result.audioAvailable && result.audioUrl != null) {
      await _playAudio(result.audioUrl!, result.cacheKey);
    }

    // Subtitles are the fallback pacing when there is no audio to follow.
    if (!_audioPlaying) _startSubtitleTimer();

    _buildController.forward();
  }

  Future<void> _playAudio(String url, String cacheKey) async {
    try {
      _subs.add(_player.onPlayerComplete.listen((_) {
        if (!mounted) return;
        // The score comes back up as the last words fade.
        ThemeMusicService.instance.unduck();
        _advanceToEnd();
      }));

      // Drive subtitles from real playback position so words match the voice.
      _subs.add(_player.onPositionChanged.listen((position) {
        if (!mounted || _lines.isEmpty) return;
        final total = _audioDuration;
        if (total == null || total.inMilliseconds == 0) return;
        final fraction = position.inMilliseconds / total.inMilliseconds;
        final index =
            (fraction * _lines.length).floor().clamp(0, _lines.length - 1);
        if (index != _lineIndex) setState(() => _lineIndex = index);
      }));

      _subs.add(_player.onDurationChanged.listen((d) {
        _audioDuration = d;
        // Match the build animation to the actual narration length so the
        // castle finishes rising exactly as the voice stops.
        if (d.inSeconds > 3 && mounted) {
          _buildController.duration = d + const Duration(seconds: 3);
          if (_buildController.isAnimating) {
            _buildController
              ..stop()
              ..forward(from: _buildController.value);
          }
        }
      }));

      final audioFile = await _downloadAudioFile(url, cacheKey);

      // Route narration to the media stream. Focus is requested as
      // transient-may-duck rather than gain: exclusive gain tells the system to
      // stop other output, which on Android silences the theme score for the
      // whole cinematic. The score is instead ducked manually just below.
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
      await _player.setVolume(1.0);
      await _player.play(DeviceFileSource(audioFile.path));
      // Pull the score down so the narrator stays intelligible.
      ThemeMusicService.instance.duck();
      if (mounted) setState(() => _audioPlaying = true);
      // StateError from the download is an Error, not an Exception — catch both
      // or a 404 leaves the intro frozen with no subtitles and no animation.
    } catch (e) {
      debugPrint('WorldGeneration: audio playback failed: $e');
      if (mounted) setState(() => _audioPlaying = false);
    }
  }

  /// Fetches the narration mp3 into the device's Downloads folder and returns
  /// it, reusing the file if a previous run already saved it.
  ///
  /// Downloads is used so the generated voice is a real, inspectable file; a
  /// cached hit also means the intro replays with no network at all.
  Future<File> _downloadAudioFile(String url, String cacheKey) async {
    final safeKey = cacheKey.trim().isEmpty ? 'intro' : cacheKey.trim();
    final directory = await _audioDirectory();
    final file = File(
      '${directory.path}${Platform.pathSeparator}knowledgeverse_intro_$safeKey.mp3',
    );

    // mp3 headers alone run ~1KB, so this threshold also rejects a previous
    // truncated write rather than trying to play it.
    if (await file.exists() && await file.length() > 4096) {
      debugPrint('WorldGeneration: reusing saved narration ${file.path}');
      return file;
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw StateError('Audio download failed with HTTP ${response.statusCode}');
    }

    await file.writeAsBytes(response.bodyBytes, flush: true);
    debugPrint(
      'WorldGeneration: saved narration to ${file.path} '
      '(${response.bodyBytes.length} bytes)',
    );
    return file;
  }

  /// Downloads folder where the platform exposes one, app storage otherwise.
  ///
  /// getDownloadsDirectory throws UnsupportedError on Android, so Android goes
  /// through getExternalStorageDirectories instead — that yields an
  /// app-private Downloads folder which is visible over USB/file manager and
  /// needs no runtime storage permission.
  Future<Directory> _audioDirectory() async {
    Directory? directory;

    if (Platform.isAndroid) {
      final external = await getExternalStorageDirectories(
        type: StorageDirectory.downloads,
      );
      if (external != null && external.isNotEmpty) directory = external.first;
    } else {
      try {
        directory = await getDownloadsDirectory();
      } on UnsupportedError {
        directory = null;
      }
    }

    directory ??= await getApplicationDocumentsDirectory();

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  void _startSubtitleTimer() {
    if (_lines.isEmpty) return;
    // ~2.6s per line approximates a natural narration cadence.
    _subtitleTimer = Timer.periodic(const Duration(milliseconds: 2600), (t) {
      if (!mounted) return;
      if (_lineIndex >= _lines.length - 1) {
        t.cancel();
        return;
      }
      setState(() => _lineIndex++);
    });
  }

  void _advanceToEnd() {
    if (_buildController.value < 1.0) {
      _buildController.animateTo(1.0,
          duration: const Duration(seconds: 2), curve: Curves.easeOut);
    }
    if (mounted) setState(() => _finished = true);
  }

  static List<String> _splitIntoLines(String text) {
    final sentences = text
        .split(RegExp(r'(?<=[.!?])\s+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return sentences.isEmpty ? [text] : sentences;
  }

  void _enterWorld() {
    _player.stop();
    // The castle screens own the score; the rest of the app runs quiet.
    ThemeMusicService.instance.fadeOutAndStop();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const WorldArchipelagoScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _subtitleTimer?.cancel();
    for (final s in _subs) {
      s.cancel();
    }
    _buildController.removeListener(_onBuildTick);
    _buildController.dispose();
    _cloudController.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final palette = _themePalette(widget.profile.worldTheme);

    return Scaffold(
      backgroundColor: HogwartsColors.midnight,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Night sky — warms very slightly as the castle wakes.
          AnimatedBuilder(
            animation: _buildController,
            builder: (context, _) {
              final t = _buildController.value.clamp(0.0, 1.0);
              return DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.lerp(HogwartsColors.midnight, palette.skyTop, t)!,
                      Color.lerp(
                          HogwartsColors.deepNight, palette.skyMid, t * 0.85)!,
                      Color.lerp(
                          HogwartsColors.duskBlue, palette.horizon, t * 0.7)!,
                    ],
                  ),
                ),
              );
            },
          ),

          // The castle itself
          AnimatedBuilder(
            animation: Listenable.merge([_buildController, _cloudController]),
            builder: (context, _) {
              return CustomPaint(
                painter: _HogwartsPainter(
                  progress: _buildController.value,
                  drift: _cloudController.value,
                  palette: palette,
                ),
                size: size,
              );
            },
          ),

          // Vignette for cinematic framing
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 1.05,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.72),
                ],
              ),
            ),
          ),

          // Top status
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: Row(
                  children: [
                    _GildedPill(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _audioPlaying
                                ? Icons.auto_awesome
                                : Icons.local_fire_department_rounded,
                            size: 13,
                            color: HogwartsColors.candle,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            _status,
                            style: HogwartsText.scroll(
                              fontSize: 12,
                              color: HogwartsColors.parchment,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (_ready)
                      GestureDetector(
                        onTap: _enterWorld,
                        child: _GildedPill(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'SKIP',
                                style: HogwartsText.display(
                                  fontSize: 10,
                                  letterSpacing: 1.8,
                                  color: HogwartsColors.candle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Icon(Icons.fast_forward_rounded,
                                  size: 13, color: HogwartsColors.candle),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Narration subtitles
          Positioned(
            left: 0,
            right: 0,
            bottom: 92,
            child: _ready ? _buildSubtitle() : _buildPreparing(),
          ),

          // Enter button once the castle stands
          if (_finished || _buildController.value >= 0.98)
            Positioned(
              left: 0,
              right: 0,
              bottom: 26,
              child: Center(
                child: GestureDetector(
                  onTap: _enterWorld,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 34, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          HogwartsColors.deepGold,
                          HogwartsColors.gold,
                          HogwartsColors.deepGold,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: HogwartsColors.candleCore.withValues(alpha: 0.7),
                        width: 1.4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: HogwartsColors.candle.withValues(alpha: 0.45),
                          blurRadius: 26,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_stories_rounded,
                            color: HogwartsColors.inkBrown, size: 19),
                        const SizedBox(width: 9),
                        Text(
                          'ENTER THE CASTLE',
                          style: HogwartsText.display(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.4,
                            color: HogwartsColors.inkBrown,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.4),
            ),
        ],
      ),
    );
  }

  Widget _buildPreparing() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(HogwartsColors.gold),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'The Sorting Hat is considering you...',
            style: HogwartsText.scroll(
              fontSize: 15,
              color: HogwartsColors.parchment,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// Narration on an illuminated strip of parchment.
  Widget _buildSubtitle() {
    if (_lines.isEmpty) return const SizedBox.shrink();
    final line = _lines[_lineIndex.clamp(0, _lines.length - 1)];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                HogwartsColors.parchment.withValues(alpha: 0.93),
                HogwartsColors.parchmentDim.withValues(alpha: 0.90),
              ],
            ),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: HogwartsColors.gold.withValues(alpha: 0.85),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: HogwartsColors.candle.withValues(alpha: 0.22),
                blurRadius: 30,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
            child: Text(
              line,
              key: ValueKey(_lineIndex),
              textAlign: TextAlign.center,
              style: HogwartsText.scroll(
                fontSize: 17,
                fontWeight: FontWeight.w400,
                height: 1.55,
                color: HogwartsColors.inkBrown,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Each world theme keeps its identity, re-voiced for a night sky.
  static _Palette _themePalette(String theme) {
    switch (theme) {
      case 'Desert Kingdom':
        return const _Palette(
          skyTop: Color(0xFF1A1024),
          skyMid: Color(0xFF3A2038),
          horizon: Color(0xFF7A4030),
          water: Color(0xFF1E1424),
          waterSheen: Color(0xFF4A2E3E),
          stone: Color(0xFF4A3A2E),
          stoneLight: Color(0xFF5E4A38),
          roof: Color(0xFF3A2A1E),
          tree: Color(0xFF2E3A24),
        );
      case 'Frozen Peaks':
        return const _Palette(
          skyTop: Color(0xFF060D1E),
          skyMid: Color(0xFF102240),
          horizon: Color(0xFF2E4E76),
          water: Color(0xFF0A1830),
          waterSheen: Color(0xFF244468),
          stone: Color(0xFF2E3648),
          stoneLight: Color(0xFF44506A),
          roof: Color(0xFF1C2334),
          tree: Color(0xFF16302C),
        );
      case 'Sky Islands':
        return const _Palette(
          skyTop: Color(0xFF0A0A22),
          skyMid: Color(0xFF1A1A48),
          horizon: Color(0xFF453A78),
          water: Color(0xFF0E1030),
          waterSheen: Color(0xFF2A2C60),
          stone: Color(0xFF32304A),
          stoneLight: Color(0xFF464464),
          roof: Color(0xFF22203A),
          tree: Color(0xFF1E3038),
        );
      case 'Green Highlands':
      default:
        return const _Palette(
          skyTop: HogwartsColors.midnight,
          skyMid: HogwartsColors.deepNight,
          horizon: HogwartsColors.moonHaze,
          water: HogwartsColors.lake,
          waterSheen: HogwartsColors.lakeSheen,
          stone: HogwartsColors.stone,
          stoneLight: HogwartsColors.stoneLight,
          roof: HogwartsColors.roofSlate,
          tree: Color(0xFF12281C),
        );
    }
  }
}

/// Small dark plaque with a thin gold edge — used for the status and skip chips.
class _GildedPill extends StatelessWidget {
  const _GildedPill({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: HogwartsColors.gold.withValues(alpha: 0.5),
        ),
      ),
      child: child,
    );
  }
}

class _Stage {
  const _Stage(this.at, this.label);
  final double at;
  final String label;
}

class _Palette {
  const _Palette({
    required this.skyTop,
    required this.skyMid,
    required this.horizon,
    required this.water,
    required this.waterSheen,
    required this.stone,
    required this.stoneLight,
    required this.roof,
    required this.tree,
  });

  final Color skyTop;
  final Color skyMid;
  final Color horizon;
  final Color water;
  final Color waterSheen;
  final Color stone;
  final Color stoneLight;
  final Color roof;
  final Color tree;
}

/// Builds the cinematic painter outside a live screen, so the paint code can be
/// exercised across its whole progress range without a network round-trip.
@visibleForTesting
CustomPainter debugHogwartsPainter({
  required double progress,
  required double drift,
  String worldTheme = 'Green Highlands',
}) {
  return _HogwartsPainter(
    progress: progress,
    drift: drift,
    palette: _WorldGenerationScreenState._themePalette(worldTheme),
  );
}

/// Paints Hogwarts revealing itself across the lake.
///
/// Each element owns a slice of [progress] — stars, moon, water, cliff, forest,
/// towers, bridge, windows, owls — so the castle assembles continuously instead
/// of popping in. [drift] runs on its own repeating clock for mist, ripples,
/// twinkle and wingbeats.
class _HogwartsPainter extends CustomPainter {
  _HogwartsPainter({
    required this.progress,
    required this.drift,
    required this.palette,
  });

  final double progress;
  final double drift;
  final _Palette palette;

  /// Fixed seed keeps the layout stable across repaints.
  static final math.Random _rng = math.Random(20260726);
  static final List<double> _starX = List.generate(90, (_) => _rng.nextDouble());
  static final List<double> _starY = List.generate(90, (_) => _rng.nextDouble());
  static final List<double> _starMag =
      List.generate(90, (_) => _rng.nextDouble());
  static final List<double> _treeSeed =
      List.generate(34, (_) => _rng.nextDouble());
  static final List<double> _treeHeight =
      List.generate(34, (_) => _rng.nextDouble());

  static double _phase(double p, double start, double end) {
    if (p <= start) return 0;
    if (p >= end) return 1;
    return ((p - start) / (end - start)).clamp(0.0, 1.0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Waterline sits low so the castle silhouette dominates the frame.
    final waterY = h * 0.66;
    // Cliff top — the castle is founded on this.
    final cliffY = h * 0.40;

    _paintStars(canvas, w, h);
    _paintMoon(canvas, w, h);
    _paintLake(canvas, w, h, waterY);
    _paintCliff(canvas, w, h, waterY, cliffY);
    _paintForest(canvas, w, waterY, cliffY);
    _paintCastle(canvas, w, cliffY);
    _paintViaduct(canvas, w, waterY, cliffY);
    _paintReflection(canvas, w, h, waterY, cliffY);
    _paintMist(canvas, w, waterY);
    _paintOwls(canvas, w, h);
    _paintFloatingCandles(canvas, w, h);
  }

  // ── Sky ──────────────────────────────────────────────────────────────

  void _paintStars(Canvas canvas, double w, double h) {
    // Stars are the first thing present and dim slightly as the castle lights.
    final appear = _phase(progress, 0.0, 0.12);
    final fade = 1.0 - _phase(progress, 0.62, 1.0) * 0.35;
    if (appear <= 0) return;

    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < _starX.length; i++) {
      final x = _starX[i] * w;
      final y = _starY[i] * h * 0.55;
      // Each star twinkles on its own offset so the field never pulses as one.
      final twinkle =
          0.55 + 0.45 * math.sin(drift * math.pi * 2 * (1.4 + _starMag[i]) + i);
      final radius = 0.5 + _starMag[i] * 1.5;
      paint.color = Colors.white
          .withValues(alpha: (0.28 + _starMag[i] * 0.62) * twinkle * appear * fade);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  void _paintMoon(Canvas canvas, double w, double h) {
    final appear = _phase(progress, 0.02, 0.18);
    if (appear <= 0) return;

    final center = Offset(w * 0.80, h * 0.16);
    const radius = 34.0;

    canvas.drawCircle(
      center,
      radius * 2.6,
      Paint()
        ..color = HogwartsColors.candle.withValues(alpha: 0.10 * appear)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 44),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = const Color(0xFFF6EFD8).withValues(alpha: 0.92 * appear),
    );
    // A couple of craters keep it from reading as a plain disc.
    final crater = Paint()
      ..color = const Color(0xFFDCD2B4).withValues(alpha: 0.5 * appear);
    canvas.drawCircle(center.translate(-9, -7), 6.5, crater);
    canvas.drawCircle(center.translate(8, 6), 4.5, crater);
    canvas.drawCircle(center.translate(3, -13), 3.0, crater);
  }

  // ── Water ────────────────────────────────────────────────────────────

  void _paintLake(Canvas canvas, double w, double h, double waterY) {
    final fill = _phase(progress, 0.06, 0.24);
    if (fill <= 0) return;

    canvas.drawRect(
      Rect.fromLTRB(0, waterY, w, h),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, waterY),
          Offset(0, h),
          [
            Color.lerp(palette.water, palette.waterSheen, 0.55)!
                .withValues(alpha: fill),
            palette.water.withValues(alpha: fill),
          ],
        ),
    );

    // Moonlight glitter path, widening toward the viewer.
    final glitter = _phase(progress, 0.10, 0.30);
    if (glitter > 0) {
      final paint = Paint()..style = PaintingStyle.fill;
      for (var i = 0; i < 34; i++) {
        final t = i / 34;
        final y = waterY + t * (h - waterY);
        final spread = 12 + t * 90;
        final wobble = math.sin(drift * math.pi * 2 + i * 0.9) * spread;
        final width = (26 - t * 12) * (0.6 + 0.4 * math.sin(i * 2.1));
        paint.color = HogwartsColors.candleCore
            .withValues(alpha: (0.16 - t * 0.11).clamp(0.0, 1.0) * glitter);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(w * 0.80 + wobble, y),
              width: width,
              height: 2.0,
            ),
            const Radius.circular(2),
          ),
          paint,
        );
      }
    }
  }

  /// The castle upside down in the water — the shot that sells the location.
  void _paintReflection(
      Canvas canvas, double w, double h, double waterY, double cliffY) {
    final show = _phase(progress, 0.46, 0.80);
    if (show <= 0) return;

    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, waterY, w, h));
    // Mirror about the waterline, then squash — reflections foreshorten.
    canvas.translate(0, waterY * 2);
    canvas.scale(1, -0.55);

    canvas.saveLayer(
      Rect.fromLTRB(0, 0, w, waterY),
      Paint()..color = Colors.white.withValues(alpha: 0.30 * show),
    );
    _paintCliff(canvas, w, h, waterY, cliffY, reflection: true);
    _paintCastle(canvas, w, cliffY, reflection: true);
    canvas.restore();
    canvas.restore();

    // Horizontal ripple bands break up the mirror so it reads as water.
    final ripple = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < 22; i++) {
      final t = i / 22;
      final y = waterY + t * (h - waterY) * 0.7;
      final offset = math.sin(drift * math.pi * 2 * 1.3 + i * 0.7) * 6;
      ripple.color = palette.water.withValues(alpha: 0.30 * show);
      canvas.drawRect(
        Rect.fromLTWH(offset - 20, y, w + 40, 1.6 + t * 2.2),
        ripple,
      );
    }
  }

  void _paintMist(Canvas canvas, double w, double waterY) {
    // Thickest at the start, burning off as the castle emerges.
    final density = 0.9 - _phase(progress, 0.0, 0.50) * 0.62;
    if (density <= 0) return;

    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 26);

    for (var i = 0; i < 5; i++) {
      final speed = 0.25 + i * 0.16;
      final x = ((drift * speed + i * 0.31) % 1.35) * (w + 420) - 210;
      final y = waterY - 26 + i * 13;
      paint.color = HogwartsColors.moonHaze
          .withValues(alpha: (0.20 - i * 0.025) * density);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x, y),
            width: 340 - i * 30,
            height: 40 - i * 3,
          ),
          const Radius.circular(999),
        ),
        paint,
      );
    }
  }

  // ── Land ─────────────────────────────────────────────────────────────

  void _paintCliff(
    Canvas canvas,
    double w,
    double h,
    double waterY,
    double cliffY, {
    bool reflection = false,
  }) {
    final rise = _phase(progress, 0.08, 0.30);
    if (rise <= 0) return;

    // The rock face grows up out of the water rather than sliding in.
    final top = waterY - (waterY - cliffY) * rise;

    final cliff = Path()
      ..moveTo(w * 0.10, waterY + 6)
      ..lineTo(w * 0.17, top + 40)
      ..lineTo(w * 0.26, top + 12)
      ..lineTo(w * 0.38, top + 26)
      ..lineTo(w * 0.50, top + 4)
      ..lineTo(w * 0.63, top + 20)
      ..lineTo(w * 0.74, top + 34)
      ..lineTo(w * 0.86, waterY + 6)
      ..close();

    canvas.drawPath(
      cliff,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, top),
          Offset(0, waterY),
          [
            palette.stone.withValues(alpha: reflection ? 0.85 : 1.0),
            HogwartsColors.stoneDark.withValues(alpha: reflection ? 0.85 : 1.0),
          ],
        ),
    );

    // Moonlit edge along the upper left.
    if (!reflection) {
      canvas.drawPath(
        Path()
          ..moveTo(w * 0.17, top + 40)
          ..lineTo(w * 0.26, top + 12)
          ..lineTo(w * 0.38, top + 26)
          ..lineTo(w * 0.50, top + 4),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = palette.stoneLight.withValues(alpha: 0.55 * rise),
      );
    }
  }

  void _paintForest(Canvas canvas, double w, double waterY, double cliffY) {
    final grow = _phase(progress, 0.22, 0.44);
    if (grow <= 0) return;

    final visible = (_treeSeed.length * grow).ceil();
    for (var i = 0; i < visible; i++) {
      // Trees hug the shoreline on both flanks, clear of the castle footprint.
      final onLeft = i.isEven;
      final spread = _treeSeed[i];
      final x = onLeft ? spread * w * 0.20 : w * 0.82 + spread * w * 0.18;
      final baseY = waterY + 4 + _treeHeight[i] * 14;
      final height = (26 + _treeHeight[i] * 40) *
          ((grow * _treeSeed.length - i).clamp(0.0, 1.0));
      if (height <= 1) continue;
      _drawPine(canvas, Offset(x, baseY), height);
    }

    // A darker band of forest tucked behind the cliff line.
    final band = Paint()..color = palette.tree.withValues(alpha: 0.75 * grow);
    final path = Path()..moveTo(0, waterY + 10);
    for (var i = 0; i <= 30; i++) {
      final t = i / 30;
      final x = t * w;
      final jag = math.sin(t * 22) * 7 + math.sin(t * 7) * 12;
      path.lineTo(x, waterY - 14 + jag * 0.6);
    }
    path
      ..lineTo(w, waterY + 10)
      ..close();
    // Only the flanks — the middle is cliff and castle.
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, cliffY, w * 0.14, waterY + 12));
    canvas.drawPath(path, band);
    canvas.restore();
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(w * 0.86, cliffY, w, waterY + 12));
    canvas.drawPath(path, band);
    canvas.restore();
  }

  void _drawPine(Canvas canvas, Offset base, double height) {
    final paint = Paint()..color = palette.tree;
    final width = height * 0.42;
    // Three stacked skirts read as a conifer at this scale.
    for (var tier = 0; tier < 3; tier++) {
      final t = tier / 3;
      final tierTop = base.dy - height + height * t * 0.62;
      final tierWidth = width * (1 - t * 0.34);
      canvas.drawPath(
        Path()
          ..moveTo(base.dx, tierTop)
          ..lineTo(base.dx - tierWidth / 2, tierTop + height * 0.42)
          ..lineTo(base.dx + tierWidth / 2, tierTop + height * 0.42)
          ..close(),
        paint,
      );
    }
  }

  // ── Castle ───────────────────────────────────────────────────────────

  /// Tower layout: x centre (fraction of width), height, width, spire flag.
  static const List<List<double>> _towers = [
    [0.28, 96, 30, 1],
    [0.34, 140, 26, 1],
    [0.40, 74, 34, 0],
    [0.455, 190, 40, 1], // the great central tower
    [0.52, 88, 32, 0],
    [0.575, 152, 28, 1],
    [0.635, 108, 36, 1],
    [0.70, 70, 30, 0],
  ];

  void _paintCastle(Canvas canvas, double w, double cliffY,
      {bool reflection = false}) {
    final build = _phase(progress, 0.30, 0.64);
    if (build <= 0) return;

    // Great hall block ties the towers together at the base.
    final hallGrow = _phase(progress, 0.30, 0.44);
    if (hallGrow > 0) {
      final hallHeight = 58 * hallGrow;
      final hall = Rect.fromLTRB(
        w * 0.26,
        cliffY + 30 - hallHeight,
        w * 0.72,
        cliffY + 30,
      );
      canvas.drawRect(hall, Paint()..color = palette.stone);
      canvas.drawRect(
        Rect.fromLTRB(hall.left, hall.top, hall.right, hall.top + 3),
        Paint()..color = palette.stoneLight.withValues(alpha: 0.6),
      );
      if (!reflection && hallGrow > 0.6) {
        _paintHallWindows(canvas, hall, (hallGrow - 0.6) * 2.5);
      }
    }

    for (var i = 0; i < _towers.length; i++) {
      final spec = _towers[i];
      // Towers rise in sequence, tallest ones taking a touch longer.
      final grow = ((build * _towers.length) - i).clamp(0.0, 1.0);
      if (grow <= 0) continue;

      final cx = spec[0] * w;
      final fullHeight = spec[1];
      final width = spec[2];
      final hasSpire = spec[3] == 1;
      final height = fullHeight * Curves.easeOut.transform(grow);
      final baseY = cliffY + 30;
      final body = Rect.fromLTRB(
        cx - width / 2,
        baseY - height,
        cx + width / 2,
        baseY,
      );

      canvas.drawRect(
        body,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(body.left, 0),
            Offset(body.right, 0),
            [palette.stoneLight, palette.stone, HogwartsColors.stoneDark],
            [0.0, 0.45, 1.0],
          ),
      );

      if (hasSpire) {
        // Conical roof, the signature Hogwarts silhouette.
        final spireHeight = width * 1.5 * grow;
        canvas.drawPath(
          Path()
            ..moveTo(body.left - 4, body.top)
            ..lineTo(cx, body.top - spireHeight)
            ..lineTo(body.right + 4, body.top)
            ..close(),
          Paint()..color = palette.roof,
        );
        // Banner on the tallest towers.
        if (fullHeight > 130 && grow > 0.9 && !reflection) {
          _drawBanner(canvas, Offset(cx, body.top - spireHeight), i);
        }
      } else {
        // Battlements for the squat towers.
        final merlon = Paint()..color = palette.stoneLight;
        for (var m = 0; m < 4; m++) {
          canvas.drawRect(
            Rect.fromLTWH(
              body.left + m * (width / 4) + 1,
              body.top - 7 * grow,
              width / 8,
              7 * grow,
            ),
            merlon,
          );
        }
      }

      if (!reflection) _paintTowerWindows(canvas, body, i);
    }
  }

  /// Windows light up on their own staggered schedule — this is the moment the
  /// castle stops being rock and starts being inhabited.
  void _paintTowerWindows(Canvas canvas, Rect body, int towerIndex) {
    final lit = _phase(progress, 0.58, 0.84);
    if (lit <= 0) return;

    final rows = ((body.height - 16) / 22).floor();
    if (rows <= 0) return;
    const cols = 2;

    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        // Deterministic stagger keyed on tower/row/col.
        final seed = (towerIndex * 31 + r * 7 + c * 3) % 11 / 11.0;
        final local = ((lit * 1.6) - seed).clamp(0.0, 1.0);
        if (local <= 0) continue;

        // Slow flicker, as though candlelit.
        final flicker =
            0.82 + 0.18 * math.sin(drift * math.pi * 2 * 3 + seed * 12 + r);
        final alpha = local * flicker;

        final x = body.left + 6 + c * ((body.width - 12) / cols);
        final y = body.bottom - 18 - r * 22;
        final rect = Rect.fromLTWH(x, y, (body.width - 14) / cols, 9);

        canvas.drawRect(
          rect,
          Paint()..color = HogwartsColors.candle.withValues(alpha: alpha),
        );
        // Bloom so the light feels like it spills onto the stone.
        canvas.drawRect(
          rect.inflate(3),
          Paint()
            ..color = HogwartsColors.emberOrange.withValues(alpha: alpha * 0.30)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        );
      }
    }
  }

  void _paintHallWindows(Canvas canvas, Rect hall, double amount) {
    final glow = amount.clamp(0.0, 1.0);
    for (var i = 0; i < 7; i++) {
      final x = hall.left + 18 + i * ((hall.width - 36) / 7);
      final rect = Rect.fromLTWH(x, hall.top + 14, 13, hall.height - 26);
      // Arched tops on the great hall windows.
      final path = Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top + 6)
        ..quadraticBezierTo(
            rect.center.dx, rect.top - 5, rect.right, rect.top + 6)
        ..lineTo(rect.right, rect.bottom)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..color = HogwartsColors.candle.withValues(alpha: 0.80 * glow),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = HogwartsColors.emberOrange.withValues(alpha: 0.35 * glow)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
      );
    }
  }

  void _drawBanner(Canvas canvas, Offset tip, int index) {
    const houses = [
      [HogwartsColors.gryffindorRed, HogwartsColors.gryffindorGold],
      [HogwartsColors.slytherinGreen, HogwartsColors.slytherinSilver],
      [HogwartsColors.ravenclawBlue, HogwartsColors.ravenclawBronze],
      [HogwartsColors.hufflepuffYellow, HogwartsColors.hufflepuffBlack],
    ];
    final house = houses[index % houses.length];

    // Pole
    canvas.drawRect(
      Rect.fromLTWH(tip.dx - 0.8, tip.dy - 20, 1.6, 20),
      Paint()..color = palette.stoneLight,
    );
    // Flag, rippling on the drift clock.
    final wave = math.sin(drift * math.pi * 2 * 2.2) * 3;
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx + 1, tip.dy - 20)
        ..lineTo(tip.dx + 15 + wave, tip.dy - 16)
        ..lineTo(tip.dx + 13 + wave, tip.dy - 11)
        ..lineTo(tip.dx + 1, tip.dy - 8)
        ..close(),
      Paint()..color = house[0],
    );
    canvas.drawRect(
      Rect.fromLTWH(tip.dx + 1, tip.dy - 15, 9, 1.4),
      Paint()..color = house[1],
    );
  }

  /// The arched viaduct approaching the castle from the left.
  void _paintViaduct(Canvas canvas, double w, double waterY, double cliffY) {
    final build = _phase(progress, 0.50, 0.70);
    if (build <= 0) return;

    final deckY = cliffY + 62;
    final left = w * 0.02;
    final right = w * 0.28;
    final span = (right - left) * build;

    canvas.drawRect(
      Rect.fromLTWH(left, deckY, span, 9),
      Paint()..color = palette.stone,
    );
    canvas.drawRect(
      Rect.fromLTWH(left, deckY, span, 2),
      Paint()..color = palette.stoneLight.withValues(alpha: 0.7),
    );

    // Piers with arches between them.
    const piers = 5;
    for (var i = 0; i < piers; i++) {
      final x = left + (right - left) * (i / piers);
      if (x > left + span) break;
      const pierWidth = 9.0;
      canvas.drawRect(
        Rect.fromLTWH(x, deckY + 9, pierWidth, waterY - deckY - 9),
        Paint()..color = palette.stone,
      );
      // Arch opening between this pier and the next.
      final nextX = left + (right - left) * ((i + 1) / piers);
      if (nextX <= left + span) {
        final archWidth = nextX - x - pierWidth;
        if (archWidth > 4) {
          canvas.drawPath(
            Path()
              ..moveTo(x + pierWidth, deckY + 34)
              ..quadraticBezierTo(
                x + pierWidth + archWidth / 2,
                deckY + 4,
                x + pierWidth + archWidth,
                deckY + 34,
              )
              ..lineTo(x + pierWidth + archWidth, waterY)
              ..lineTo(x + pierWidth, waterY)
              ..close(),
            Paint()..color = HogwartsColors.midnight.withValues(alpha: 0.85),
          );
        }
      }
    }

    // Lanterns along the deck.
    final lanterns = _phase(progress, 0.62, 0.78);
    if (lanterns > 0) {
      for (var i = 0; i < 6; i++) {
        final x = left + (right - left) * (i / 6) + 6;
        if (x > left + span) break;
        final flicker =
            0.75 + 0.25 * math.sin(drift * math.pi * 2 * 4 + i * 1.7);
        canvas.drawCircle(
          Offset(x, deckY - 4),
          2.2,
          Paint()
            ..color = HogwartsColors.candle
                .withValues(alpha: lanterns * flicker),
        );
        canvas.drawCircle(
          Offset(x, deckY - 4),
          7,
          Paint()
            ..color = HogwartsColors.emberOrange
                .withValues(alpha: lanterns * flicker * 0.28)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );
      }
    }
  }

  // ── Life ─────────────────────────────────────────────────────────────

  /// Owls crossing the moon — the arrival of the letter.
  void _paintOwls(Canvas canvas, double w, double h) {
    final fly = _phase(progress, 0.74, 0.92);
    if (fly <= 0) return;

    for (var i = 0; i < 4; i++) {
      final speed = 0.5 + i * 0.14;
      // Travels right to left across the frame on a lazy sine path.
      final t = ((drift * speed + i * 0.27) % 1.0);
      final x = w * 1.05 - t * w * 1.15;
      final y = h * (0.13 + i * 0.045) + math.sin(t * math.pi * 3) * 16;
      final scale = (0.7 + i * 0.16) * fly;
      _drawOwl(canvas, Offset(x, y), scale, t);
    }
  }

  void _drawOwl(Canvas canvas, Offset at, double scale, double t) {
    if (scale <= 0.05) return;
    // Wingbeat: the V opens and closes.
    final beat = math.sin(t * math.pi * 34) * 0.5 + 0.5;
    final span = 9.0 * scale;
    final lift = (2.0 + beat * 5.0) * scale;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7 * scale
      ..strokeCap = StrokeCap.round
      ..color = HogwartsColors.stoneDark.withValues(alpha: 0.85);

    canvas.drawPath(
      Path()
        ..moveTo(at.dx - span, at.dy - lift)
        ..quadraticBezierTo(at.dx - span * 0.4, at.dy + 1, at.dx, at.dy)
        ..quadraticBezierTo(
            at.dx + span * 0.4, at.dy + 1, at.dx + span, at.dy - lift),
      paint,
    );
  }

  /// Floating candles drifting up through the frame, Great Hall style.
  void _paintFloatingCandles(Canvas canvas, double w, double h) {
    final show = _phase(progress, 0.86, 1.0);
    if (show <= 0) return;

    for (var i = 0; i < 14; i++) {
      final seed = (i * 37 % 100) / 100.0;
      final speed = 0.10 + seed * 0.10;
      // Rises slowly and wraps, so the frame never empties out.
      final t = ((drift * speed + seed) % 1.0);
      final x = w * (0.06 + seed * 0.88) +
          math.sin(drift * math.pi * 2 + i) * 10;
      final y = h * 0.92 - t * h * 0.72;
      final flicker = 0.7 + 0.3 * math.sin(drift * math.pi * 2 * 5 + i * 2.3);
      final alpha = show * flicker * (1.0 - t * 0.45);

      // Wax stub
      canvas.drawRect(
        Rect.fromCenter(center: Offset(x, y + 4), width: 2.4, height: 7),
        Paint()
          ..color = HogwartsColors.parchment.withValues(alpha: alpha * 0.75),
      );
      // Flame
      canvas.drawCircle(
        Offset(x, y - 1),
        1.9,
        Paint()..color = HogwartsColors.candleCore.withValues(alpha: alpha),
      );
      canvas.drawCircle(
        Offset(x, y - 1),
        9,
        Paint()
          ..color = HogwartsColors.candle.withValues(alpha: alpha * 0.34)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HogwartsPainter old) =>
      old.progress != progress ||
      old.drift != drift ||
      old.palette != palette;
}
