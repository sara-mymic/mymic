import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

/// Text-to-speech tuned for short, friendly lines (Buddy).
class SparkVoiceService {
  SparkVoiceService() : _tts = FlutterTts();

  final FlutterTts _tts;
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    await _tts.setLanguage('en-US');
    await _tts.awaitSpeakCompletion(true);
    // Slightly slower + brighter for kids.
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.05);
    await _tts.setVolume(1.0);
    _ready = true;
  }

  /// Speaks [text] and completes when TTS finishes (or stops).
  Future<void> speak(String text) async {
    await init();
    await stop();
    final cleaned = sanitizeForSpeech(text);
    if (cleaned.isEmpty) return;

    final completer = Completer<void>();
    void completeOnce() {
      if (!completer.isCompleted) completer.complete();
    }

    _tts.setCompletionHandler(completeOnce);
    _tts.setErrorHandler((msg) => completeOnce());

    await _tts.speak(cleaned);
    await completer.future.timeout(
      const Duration(minutes: 2),
      onTimeout: completeOnce,
    );
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  /// Matches emoji / pictographic characters plus their modifiers
  /// (variation selector, zero-width joiner, skin tones, flag indicators).
  static final RegExp _emojiRegex = RegExp(
    r'[\p{Extended_Pictographic}\u{FE0F}\u{200D}\u{1F3FB}-\u{1F3FF}\u{1F1E6}-\u{1F1FF}]',
    unicode: true,
  );

  /// Removes emojis so TTS doesn't read "smiling face with smiling eyes" etc.
  /// Also tidies up leftover whitespace and dangling punctuation.
  static String sanitizeForSpeech(String text) {
    var cleaned = text.replaceAll(_emojiRegex, ' ');
    // Collapse runs of whitespace left behind by removed emojis.
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    // Pull punctuation back against the preceding word ("Yay !" -> "Yay!").
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'\s+([!?.,;:])'),
      (m) => m.group(1)!,
    );
    return cleaned.trim();
  }
}
