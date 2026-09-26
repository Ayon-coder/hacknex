import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/learning_models.dart';
import '../../../services/audio_narration_player.dart';
import '../../../services/learning_service.dart';
import '../../../services/student_progress_service.dart';
import '../../buildings/building_data.dart';
import '../../managers/building_manager.dart';

/// AI-Powered Building Learning Panel UI widget.
/// Interacts with Gemini AI for generated topic explanations & 4 MCQs,
/// and ElevenLabs for voice narration (explanation, tutorial, question reading).
class BuildingLearningPanel extends StatefulWidget {
  final BuildingData building;
  final VoidCallback onClose;

  const BuildingLearningPanel({
    super.key,
    required this.building,
    required this.onClose,
  });

  @override
  State<BuildingLearningPanel> createState() => _BuildingLearningPanelState();
}

class _BuildingLearningPanelState extends State<BuildingLearningPanel>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final AudioNarrationPlayer _narrationPlayer;

  bool _isLoading = true;
  LearningContentResponse? _content;
  String? _errorMessage;

  // Audio Playback State
  bool _isPlayingAudio = false;
  bool _isLoadingAudio = false;
  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;

  // Quiz State
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  bool _hasSubmittedAnswer = false;
  int _score = 0;
  bool _quizCompleted = false;
  final Map<int, int> _userAnswers = {};

  // Tutorial / How To Play text
  static const String _tutorialText =
      "Welcome to the Learning Chamber! Select the Topic tab to hear and read your AI-generated subject lesson. Then switch to the Quiz tab to answer 4 multiple-choice questions. Earning high quiz scores rewards your building with Focus XP and unlocks visual magic upgrades!";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _narrationPlayer = AudioNarrationPlayer(
      onStateChanged: (s) {
        if (mounted) setState(() => _isPlayingAudio = s == PlayerState.playing);
      },
      onPositionChanged: (p) {
        if (mounted) setState(() => _audioPosition = p);
      },
      onDurationChanged: (d) {
        if (mounted) setState(() => _audioDuration = d);
      },
    );
    _fetchContent();
  }

  BuildingData get _currentBuilding =>
      BuildingManager().getBuilding(widget.building.id) ?? widget.building;

  String _difficultyForLevel(int level) {
    if (level <= 1) return 'Beginner';
    if (level == 2) return 'Intermediate';
    if (level == 3) return 'Advanced';
    if (level == 4) return 'Master';
    return 'Expert';
  }

  String _levelTitle(int level) {
    if (level <= 1) return 'Level 1 (Beginner)';
    if (level == 2) return 'Level 2 (Intermediate - Harder)';
    if (level == 3) return 'Level 3 (Advanced)';
    if (level == 4) return 'Level 4 (Master)';
    return 'Level $level (Expert)';
  }

  String _levelBadgeText(int level) {
    if (level <= 1) return 'LV.1 • EASY';
    if (level == 2) return 'LV.2 • HARDER';
    if (level == 3) return 'LV.3 • ADVANCED';
    if (level == 4) return 'LV.4 • MASTER';
    return 'LV.$level • EXPERT';
  }

  Future<void> _fetchContent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final currentBuilding = _currentBuilding;
      final difficulty = _difficultyForLevel(currentBuilding.level);
      final req = LearningRequest(
        buildingId: currentBuilding.id,
        buildingName: currentBuilding.name,
        subject: currentBuilding.subject,
        difficulty: difficulty,
        studentLevel: currentBuilding.level,
      );

      final response = await LearningService.fetchLearningContent(req);

      if (mounted) {
        setState(() {
          _content = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to load learning content. Please try again.";
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _narrationPlayer.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _playAudioUrl(String url, {String? cacheKey}) async {
    try {
      setState(() => _isLoadingAudio = true);
      final success = await _narrationPlayer.playUrl(url, cacheKey: cacheKey);
      setState(() => _isLoadingAudio = false);
      if (!success) {
        _showToast("Unable to play voice narration.");
      }
    } catch (e) {
      debugPrint('Audio playback error: $e');
      if (mounted) setState(() => _isLoadingAudio = false);
    }
  }

  Future<void> _togglePlayExplanationAudio() async {
    if (_isPlayingAudio) {
      await _narrationPlayer.pause();
    } else if (_audioPosition > Duration.zero && _audioPosition < _audioDuration) {
      await _narrationPlayer.resume();
    } else {
      final url = _content?.explanationAudioUrl;
      final key = _content?.cacheKey;
      if (url != null && url.isNotEmpty) {
        await _playAudioUrl(url, cacheKey: key);
      } else if (_content != null && _content!.explanation.isNotEmpty) {
        setState(() => _isLoadingAudio = true);
        final generatedUrl = await LearningService.fetchTTSAudioUrl(_content!.explanation);
        setState(() => _isLoadingAudio = false);
        if (generatedUrl != null) {
          await _playAudioUrl(generatedUrl);
        } else {
          _showToast("Voice narration unavailable for this section.");
        }
      }
    }
  }

  Future<void> _playQuestionAudio(String text) async {
    setState(() => _isLoadingAudio = true);
    final url = await LearningService.fetchTTSAudioUrl(text);
    setState(() => _isLoadingAudio = false);

    if (url != null) {
      await _playAudioUrl(url);
    } else {
      _showToast("Voice reading unavailable.");
    }
  }

  Future<void> _playTutorialAudio() async {
    setState(() => _isLoadingAudio = true);
    final url = await LearningService.fetchTTSAudioUrl(_tutorialText);
    setState(() => _isLoadingAudio = false);

    if (url != null) {
      await _playAudioUrl(url);
    } else {
      _showToast("Tutorial voice unavailable.");
    }
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _selectAnswer(int optionIndex) {
    if (_hasSubmittedAnswer) return;
    setState(() {
      _selectedOptionIndex = optionIndex;
    });
  }

  void _submitAnswer() {
    if (_selectedOptionIndex == null || _content == null) return;
    final currentQ = _content!.questions[_currentQuestionIndex];
    final isCorrect = _selectedOptionIndex == currentQ.correctIndex;

    setState(() {
      _hasSubmittedAnswer = true;
      _userAnswers[_currentQuestionIndex] = _selectedOptionIndex!;
      if (isCorrect) {
        _score += 1;
      }
    });
  }

  Future<void> _nextQuestion() async {
    if (_content == null) return;
    if (_currentQuestionIndex < _content!.questions.length - 1) {
      setState(() {
        _currentQuestionIndex += 1;
        _selectedOptionIndex = null;
        _hasSubmittedAnswer = false;
      });
    } else {
      // Finish Quiz & Award Building XP
      final int xpAward = _score * 50 + 50;
      BuildingManager().addXp(widget.building.id, xpAward);
      await StudentProgress.recordQuiz(
        answered: _content!.questions.length,
        correct: _score,
      );
      setState(() {
        _quizCompleted = true;
      });
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _selectedOptionIndex = null;
      _hasSubmittedAnswer = false;
      _score = 0;
      _quizCompleted = false;
      _userAnswers.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.building.themeColor;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 680),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: themeColor, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: themeColor.withValues(alpha: 0.35),
              blurRadius: 24,
              spreadRadius: 2,
            ),
            const BoxShadow(
              color: Colors.black87,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // --- Panel Header ---
            _buildPanelHeader(themeColor),

            // --- Navigation Tab Bar ---
            TabBar(
              controller: _tabController,
              indicatorColor: themeColor,
              labelColor: themeColor,
              unselectedLabelColor: const Color(0xFFA6ADC8),
              labelStyle: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              tabs: const [
                Tab(icon: Icon(Icons.auto_awesome, size: 18), text: "Explanation"),
                Tab(icon: Icon(Icons.quiz, size: 18), text: "Quiz (4 MCQs)"),
                Tab(icon: Icon(Icons.help_outline, size: 18), text: "How to Play"),
              ],
            ),

            const Divider(color: Color(0xFF313244), height: 1),

            // --- Panel Body Content ---
            Expanded(
              child: _isLoading
                  ? _buildLoadingState(themeColor)
                  : _errorMessage != null
                      ? _buildErrorState(themeColor)
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildExplanationTab(themeColor),
                            _buildQuizTab(themeColor),
                            _buildTutorialTab(themeColor),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds top header with building icon, name, level tag, and close button.
  Widget _buildPanelHeader(Color themeColor) {
    final currentBuilding = _currentBuilding;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFF181825),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: themeColor, width: 1.5),
            ),
            child: Icon(currentBuilding.icon, color: themeColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        currentBuilding.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: themeColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: themeColor.withValues(alpha: 0.6), width: 1),
                      ),
                      child: Text(
                        _levelBadgeText(currentBuilding.level),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: themeColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${currentBuilding.subject} • ${_levelTitle(currentBuilding.level)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: themeColor,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: widget.onClose,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF313244),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: const Icon(Icons.close, color: Colors.white70, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds loading indicator while Gemini AI generates content.
  Widget _buildLoadingState(Color themeColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3.5,
              valueColor: AlwaysStoppedAnimation<Color>(themeColor),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Consulting Gemini AI...",
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Generating personalized lesson & 4 MCQs for ${_levelTitle(_currentBuilding.level)}",
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFA6ADC8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds error state with retry button.
  Widget _buildErrorState(Color themeColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 48, color: Color(0xFFF38BA8)),
            const SizedBox(height: 14),
            Text(
              _errorMessage ?? "An error occurred",
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: const Color(0xFF181825),
              ),
              onPressed: _fetchContent,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds Topic Explanation Tab with ElevenLabs Voice Narration controls.
  Widget _buildExplanationTab(Color themeColor) {
    if (_content == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Topic Title Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: themeColor.withValues(alpha: 0.4)),
            ),
            child: Text(
              _content!.topic,
              style: GoogleFonts.plusJakartaSans(
                color: themeColor,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- Voice Narration Audio Player Card ---
          _buildAudioPlayerBar(
            title: "Voice Explanation (ElevenLabs)",
            onPlayToggle: _togglePlayExplanationAudio,
            themeColor: themeColor,
          ),

          const SizedBox(height: 20),

          // Concise Topic Explanation Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF181825),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF313244)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, size: 20, color: themeColor),
                    const SizedBox(width: 8),
                    Text(
                      "CONCEPT OVERVIEW",
                      style: GoogleFonts.plusJakartaSans(
                        color: themeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _content!.explanation,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFCDD6F4),
                    fontSize: 14,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 20),

          // Action button to start quiz
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: const Color(0xFF181825),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(
                "START 4-QUESTION QUIZ",
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 0.8,
                ),
              ),
              onPressed: () {
                _tabController.animateTo(1);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds Audio Control Bar Widget
  Widget _buildAudioPlayerBar({
    required String title,
    required VoidCallback onPlayToggle,
    required Color themeColor,
  }) {
    final double maxSec = _audioDuration.inMilliseconds.toDouble();
    final double currentSec = _audioPosition.inMilliseconds.toDouble().clamp(0.0, maxSec > 0 ? maxSec : 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF27273A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: themeColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: const Color(0xFF181825),
                ),
                icon: _isLoadingAudio
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : Icon(_isPlayingAudio ? Icons.pause : Icons.play_arrow),
                onPressed: onPlayToggle,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isPlayingAudio ? "Playing Narration..." : "Tap play to listen",
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFA6ADC8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.graphic_eq, color: Color(0xFFA6ADC8), size: 20),
            ],
          ),
          if (maxSec > 0) ...[
            const SizedBox(height: 4),
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                activeTrackColor: themeColor,
                inactiveTrackColor: Colors.white12,
                thumbColor: themeColor,
              ),
              child: Slider(
                value: currentSec,
                max: maxSec > 0 ? maxSec : 1.0,
                onChanged: (val) {
                  _narrationPlayer.seek(Duration(milliseconds: val.toInt()));
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds 4 Multiple-Choice Questions Quiz Tab.
  Widget _buildQuizTab(Color themeColor) {
    if (_content == null || _content!.questions.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_quizCompleted) {
      return _buildQuizCompletedView(themeColor);
    }

    final currentQ = _content!.questions[_currentQuestionIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Progress Indicator & Level Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "QUESTION ${_currentQuestionIndex + 1} OF ${_content!.questions.length}",
                    style: GoogleFonts.plusJakartaSans(
                      color: themeColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: themeColor.withValues(alpha: 0.5), width: 1),
                    ),
                    child: Text(
                      _levelBadgeText(_currentBuilding.level),
                      style: GoogleFonts.plusJakartaSans(
                        color: themeColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.volume_up, color: Color(0xFF89B4FA), size: 20),
                tooltip: "Read Question Aloud",
                onPressed: () => _playQuestionAudio(currentQ.question),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Linear progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _content!.questions.length,
              backgroundColor: const Color(0xFF313244),
              valueColor: AlwaysStoppedAnimation<Color>(themeColor),
              minHeight: 6,
            ),
          ),

          const SizedBox(height: 18),

          // Question Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF181825),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF313244)),
            ),
            child: Text(
              currentQ.question,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 18),

          // 4 Options
          ...List.generate(4, (index) {
            final optionText = currentQ.options[index];
            final isSelected = _selectedOptionIndex == index;
            final isCorrect = index == currentQ.correctIndex;

            Color optionBg = const Color(0xFF181825);
            Color optionBorder = const Color(0xFF313244);
            Color textColor = Colors.white;

            if (_hasSubmittedAnswer) {
              if (isCorrect) {
                optionBg = const Color(0xFFA6E3A1).withValues(alpha: 0.2);
                optionBorder = const Color(0xFFA6E3A1);
                textColor = const Color(0xFFA6E3A1);
              } else if (isSelected) {
                optionBg = const Color(0xFFF38BA8).withValues(alpha: 0.2);
                optionBorder = const Color(0xFFF38BA8);
                textColor = const Color(0xFFF38BA8);
              }
            } else if (isSelected) {
              optionBg = themeColor.withValues(alpha: 0.2);
              optionBorder = themeColor;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => _selectAnswer(index),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: optionBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: optionBorder, width: isSelected || (_hasSubmittedAnswer && isCorrect) ? 2 : 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: optionBorder.withValues(alpha: 0.3),
                        ),
                        child: Text(
                          String.fromCharCode(65 + index), // A, B, C, D
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          optionText,
                          style: GoogleFonts.plusJakartaSans(
                            color: textColor,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // Answer Explanation Box (After submission)
          if (_hasSubmittedAnswer) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF27273A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF89B4FA), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      currentQ.explanation,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFCDD6F4),
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(),
          ],

          const SizedBox(height: 18),

          // Submit / Next Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: const Color(0xFF181825),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _selectedOptionIndex == null
                  ? null
                  : (_hasSubmittedAnswer ? _nextQuestion : _submitAnswer),
              child: Text(
                _hasSubmittedAnswer
                    ? (_currentQuestionIndex < _content!.questions.length - 1 ? "NEXT QUESTION" : "FINISH QUIZ")
                    : "SUBMIT ANSWER",
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds Quiz Completion Summary & XP Rewards view.
  Widget _buildQuizCompletedView(Color themeColor) {
    final int xpAwarded = _score * 50 + 50;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events_rounded, size: 64, color: Color(0xFFFAB387)),
            const SizedBox(height: 16),
            Text(
              "Quiz Complete!",
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You scored $_score / 4 correct answers",
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFCDD6F4),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: themeColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt, color: themeColor, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    "+$xpAwarded Focus XP Earned!",
                    style: GoogleFonts.plusJakartaSans(
                      color: themeColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                  ),
                  onPressed: _restartQuiz,
                  child: const Text("Retake Quiz"),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: const Color(0xFF181825),
                  ),
                  onPressed: widget.onClose,
                  child: const Text("Close Panel"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds How to Play / Game Tutorial Tab with ElevenLabs voice narration.
  Widget _buildTutorialTab(Color themeColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAudioPlayerBar(
            title: "Voice Tutorial (ElevenLabs)",
            onPlayToggle: _playTutorialAudio,
            themeColor: themeColor,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF181825),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF313244)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "HOW TO LEARN & UPGRADE",
                  style: GoogleFonts.plusJakartaSans(
                    color: themeColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _tutorialText,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFCDD6F4),
                    fontSize: 13.5,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
