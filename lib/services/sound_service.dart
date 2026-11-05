
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> _play(
    String fileName,
    Future<void> Function() hapticFeedback,
  ) async {
    try {
      await hapticFeedback();
    } catch (_) {}

    try {
      await _player.play(
        AssetSource('sounds/$fileName'),
      );
    } catch (_) {}
  }

  static Future<void> playClick() =>
      _play('click.wav', HapticFeedback.lightImpact);

  static Future<void> playSuccess() =>
      _play('success.wav', HapticFeedback.mediumImpact);

  static Future<void> playFinish() =>
      _play('finish.wav', HapticFeedback.selectionClick);

  static Future<void> playFailed() =>
      _play('failed.wav', HapticFeedback.heavyImpact);

  static Future<void> playEliminated() => playFailed();
}
