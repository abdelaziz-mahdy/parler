import 'package:flutter_tts/flutter_tts.dart';

enum TtsSpeed {
  slow(0.35),
  normal(0.50);

  final double rate;
  const TtsSpeed(this.rate);
}

class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  TtsSpeed _speed = TtsSpeed.normal;

  TtsSpeed get speed => _speed;

  Future<void> init() async {
    if (_initialized) return;

    await _tts.setLanguage('fr-FR');
    await _tts.setSpeechRate(_speed.rate);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    // iOS-specific setup
    await _tts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers,
      ],
      IosTextToSpeechAudioMode.voicePrompt,
    );

    _initialized = true;
  }

  Future<void> setSpeed(TtsSpeed speed) async {
    _speed = speed;
    if (_initialized) {
      await _tts.setSpeechRate(speed.rate);
    }
  }

  /// Manual speak — triggered by user tap
  Future<void> speak(String text) async {
    await init();
    await _tts.stop();
    await _tts.speak(text);
  }

  /// Auto-play — used in sessions when card appears
  Future<void> speakAuto(String text) async {
    await init();
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  void dispose() {
    _tts.stop();
  }
}
