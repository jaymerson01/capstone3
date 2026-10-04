import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

/// Helper service for testing municipal station alert audio in the Admin Command Center.
class StationAudioService {
  static VideoPlayerController? _controller;
  static bool _isPlaying = false;

  static bool get isPlaying => _isPlaying;

  /// Plays the dual-harmonic station emergency alert chime.
  static Future<void> testAlertSound({VoidCallback? onComplete}) async {
    try {
      await _controller?.dispose();
      _controller = VideoPlayerController.asset('assets/sounds/resq_alert.wav');
      await _controller!.initialize();
      _isPlaying = true;
      await _controller!.play();

      _controller!.addListener(() {
        if (_controller != null &&
            _controller!.value.isInitialized &&
            _controller!.value.position >= _controller!.value.duration) {
          _isPlaying = false;
          _controller?.dispose();
          _controller = null;
          onComplete?.call();
        }
      });
    } catch (e) {
      debugPrint("🔊 [StationAudioService] Error playing test audio: $e");
      _isPlaying = false;
      onComplete?.call();
    }
  }

  /// Stops any currently playing alert chime.
  static Future<void> stop() async {
    try {
      if (_controller != null) {
        await _controller!.pause();
        await _controller!.dispose();
        _controller = null;
      }
      _isPlaying = false;
    } catch (_) {}
  }
}
