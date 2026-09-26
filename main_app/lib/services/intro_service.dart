import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/player_profile.dart';
import 'api_config.dart';
import 'api_service.dart';

/// Narration returned by the backend, plus how to play it.
class IntroResult {
  const IntroResult({
    required this.narration,
    required this.audioUrl,
    required this.audioAvailable,
    required this.source,
    required this.cacheKey,
  });

  final String narration;
  final String? audioUrl;
  final bool audioAvailable;

  /// "gemini", "fallback" (backend's canned text), "cache", or "offline"
  /// (backend unreachable — text composed on-device).
  final String source;
  final String cacheKey;
}

/// Fetches the cinematic intro from the backend.
///
/// The player must never be blocked by an AI failure, so every path here ends
/// in usable narration: backend retries Gemini, falls back to its own text, and
/// if the backend itself is unreachable we compose the text on-device.
class IntroService {
  IntroService._();

  static const Duration _timeout = Duration(seconds: 60);

  /// Guards against a rebuild firing a second generation for the same profile.
  static String? _cachedKey;
  static IntroResult? _cachedResult;
  static Future<IntroResult>? _inflight;

  static Future<IntroResult> fetchIntro(PlayerProfile profile) {
    final key = jsonEncode(profile.toIntroRequest());
    if (_cachedKey == key && _cachedResult != null) {
      return Future.value(_cachedResult);
    }
    // Collapse duplicate concurrent calls onto one request.
    if (_cachedKey == key && _inflight != null) return _inflight!;

    _cachedKey = key;
    _inflight = _fetch(profile, key).then((result) {
      _cachedResult = result;
      _inflight = null;
      return result;
    }).catchError((Object error) {
      _inflight = null;
      _cachedKey = null;
      throw error;
    });
    return _inflight!;
  }

  static Future<IntroResult> _fetch(PlayerProfile profile, String key) async {
    final base = ApiConfig.baseUrl;

    // Two attempts: the backend already retries Gemini internally, so this only
    // covers transport-level hiccups.
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        final response = await ApiService.post(
          '/api/intro',
          body: profile.toIntroRequest(),
          timeout: _timeout,
        );

        if (response.statusCode == 200) {
          // Force UTF-8: narration contains em dashes and curly quotes that
          // http's default latin-1 guess would mangle.
          final data = jsonDecode(utf8.decode(response.bodyBytes))
              as Map<String, dynamic>;
          final path = data['audio_url'] as String?;
          return IntroResult(
            narration: data['narration'] as String? ?? '',
            audioUrl: path == null ? null : '$base$path',
            audioAvailable: data['audio_available'] as bool? ?? false,
            source: data['source'] as String? ?? 'gemini',
            cacheKey: data['cache_key'] as String? ?? key,
          );
        }
        debugPrint('IntroService: backend returned ${response.statusCode}');
      } on Exception catch (e) {
        debugPrint('IntroService attempt $attempt failed: $e');
      }

      if (attempt == 0) {
        await Future<void>.delayed(const Duration(seconds: 1));
      }
    }

    return IntroResult(
      narration: offlineNarration(profile),
      audioUrl: null,
      audioAvailable: false,
      source: 'offline',
      cacheKey: key,
    );
  }

  /// Last-resort narration when the backend cannot be reached at all.
  @visibleForTesting
  static String offlineNarration(PlayerProfile profile) {
    final name = profile.name.trim().isEmpty ? 'Explorer' : profile.name.trim();
    final theme = profile.worldTheme.trim().isEmpty
        ? 'a quiet green valley'
        : profile.worldTheme.trim();
    return '$name — the owls have been waiting for you. '
        'Tonight the lanterns are lit, and a place has been set aside for a student '
        'of ${_subjectPhrase(profile.subjects)}. Across the water lies $theme, and above it '
        'a castle that is not yet finished, because it is yours to raise. '
        'Every lesson you master lays another stone: corridors and staircases, '
        'libraries and laboratories, towers with candles burning in every window. '
        'Your knowledge will become your castle. '
        'Step inside — your first lesson is about to begin.';
  }

  static String _subjectPhrase(List<String> subjects) {
    final clean = subjects.where((s) => s.trim().isNotEmpty).toList();
    if (clean.isEmpty) return 'many wonders';
    if (clean.length == 1) return clean.first;
    if (clean.length == 2) return '${clean[0]} and ${clean[1]}';
    return '${clean.sublist(0, clean.length - 1).join(', ')}, and ${clean.last}';
  }
}
