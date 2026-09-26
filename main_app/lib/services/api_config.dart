import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized API Configuration service for KnowledgeVerse.
///
/// Handles environment variable loading via `flutter_dotenv`.
///
/// ===========================================================================
/// HOW TO CHANGE THE BACKEND URL AFTER DEPLOYMENT:
/// ===========================================================================
/// 1. Open the `.env` file at the root of the project repository.
/// 2. Update the `API_BASE_URL` key with your new backend URL:
///
///    Development:
///    API_BASE_URL=http://127.0.0.1:8000
///
///    Production:
///    API_BASE_URL=https://your-backend-app.onrender.com
///
/// 3. Rebuild or restart the application. NO Dart source code changes are required.
/// ===========================================================================
class ApiConfig {
  static const String _defaultFallback = 'http://127.0.0.1:8000';
  static String? _cachedBaseUrl;
  static bool _initialized = false;

  /// Initializes `flutter_dotenv` and configures the centralized base URL.
  /// Should be called in `main()` before `runApp()`.
  static Future<void> init() async {
    if (_initialized) return;

    try {
      await dotenv.load(fileName: '.env');
      final envUrl = dotenv.env['API_BASE_URL']?.trim();

      if (envUrl != null && envUrl.isNotEmpty) {
        // Strip trailing slashes for clean string formatting
        _cachedBaseUrl = envUrl.endsWith('/')
            ? envUrl.substring(0, envUrl.length - 1)
            : envUrl;
        debugPrint('✅ [ApiConfig]: Loaded API_BASE_URL from .env: $_cachedBaseUrl');
      } else {
        _handleMissingEnv('API_BASE_URL key is empty or null in .env');
      }
    } catch (e) {
      _handleMissingEnv('Failed to load .env file: $e');
    }

    _initialized = true;
  }

  /// Logs a detailed error message and sets a safe fallback URL when .env is missing.
  static void _handleMissingEnv(String reason) {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('⚠️ [ApiConfig Warning]: $reason');
    debugPrint('⚠️ Falling back to default URL: $_defaultFallback');
    debugPrint('💡 Make sure a valid .env file exists with API_BASE_URL set.');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _cachedBaseUrl = _defaultFallback;
  }

  /// Returns the current backend base URL configured in `.env`.
  /// Guaranteed not to throw or crash if `.env` is missing.
  static String get baseUrl {
    if (_cachedBaseUrl != null && _cachedBaseUrl!.isNotEmpty) {
      return _cachedBaseUrl!;
    }
    // Fallback attempt to read dotenv directly if accessed before init()
    final envUrl = dotenv.env['API_BASE_URL']?.trim();
    if (envUrl != null && envUrl.isNotEmpty) {
      _cachedBaseUrl = envUrl.endsWith('/')
          ? envUrl.substring(0, envUrl.length - 1)
          : envUrl;
      return _cachedBaseUrl!;
    }
    return _defaultFallback;
  }

  /// Utility getter to check if the app is currently pointing to localhost / dev.
  static bool get isLocalDev =>
      baseUrl.contains('127.0.0.1') ||
      baseUrl.contains('localhost') ||
      baseUrl.contains('10.0.2.2');
}
