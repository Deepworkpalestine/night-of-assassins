import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class SoundService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playClick() async {
    HapticFeedback.lightImpact();
    try {
      await _player.play(AssetSource('sounds/click.wav'));
    } catch (_) {}
  }

  Future<void> playSuccess() async {
    HapticFeedback.mediumImpact();
    try {
      await _player.play(AssetSource('sounds/success.wav'));
    } catch (_) {}
  }

  Future<void> playFinish() async {
    HapticFeedback.selectionClick();
    try {
      await _player.play(AssetSource('sounds/finish.wav'));
    } catch (_) {}
  }

  Future<void> playEliminated() async {
    HapticFeedback.heavyImpact();
    try {
      await _player.play(AssetSource('sounds/failed.wav'));
    } catch (_) {}
  }
}
