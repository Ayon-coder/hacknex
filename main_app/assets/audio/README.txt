Background score for the intro screens.

Drop an MP3 here named exactly:

    hedwigs_theme.mp3

ThemeMusicService checks for that file first and plays it verbatim, looping
quietly under the narration. No code change is needed — just add the file and
rebuild.

If the file is absent, the app synthesizes an original celesta waltz at runtime
(see lib/services/theme_music_service.dart) and caches it, so the cinematic is
never silent.
