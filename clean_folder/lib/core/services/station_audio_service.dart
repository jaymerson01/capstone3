import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

/// Helper service for testing municipal station alert audio in the Admin Command Center.
class StationAudioService {
  static VideoPlayerController? _controller;
  static bool _isPlaying = false;

  static bool get isPlaying => _isPlaying;

  /// Plays the dual-harmonic station emergency alert chime.
  static Future<void> playAlertSound({VoidCallback? onComplete}) async {
    try {
      if (_controller != null) {
        await _controller!.pause();
        await _controller!.dispose();
        _controller = null;
      }
      _controller = VideoPlayerController.asset('assets/sounds/resq_alert.wav');
      await _controller!.initialize();
      await _controller!.setVolume(1.0);
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
      debugPrint("🔊 [StationAudioService] Error playing alert audio: $e");
      _isPlaying = false;
      onComplete?.call();
    }
  }

  /// Backward-compatible alias for testing station alert audio
  static Future<void> testAlertSound({VoidCallback? onComplete}) =>
      playAlertSound(onComplete: onComplete);


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

  static VideoPlayerController? _siren;

  /// Starts the loud emergency siren, looping until [stopSiren]. Used while a
  /// barangay emergency broadcast is on the resident's screen.
  static Future<void> startSiren() async {
    if (_siren != null) return;
    final siren = VideoPlayerController.asset('assets/sounds/resq_siren.wav');
    _siren = siren;
    try {
      await siren.initialize();
      // Stopped while it was loading.
      if (_siren != siren) {
        await siren.dispose();
        return;
      }
      await siren.setLooping(true);
      await siren.setVolume(1.0);
      await siren.play();
    } catch (e) {
      // Browsers may block sound until the page has been tapped once.
      debugPrint("🔊 [StationAudioService] Siren could not play: $e");
      if (_siren == siren) _siren = null;
      await siren.dispose();
    }
  }

  static Future<void> stopSiren() async {
    final siren = _siren;
    _siren = null;
    if (siren == null) return;
    try {
      await siren.pause();
      await siren.dispose();
    } catch (_) {}
  }
}
