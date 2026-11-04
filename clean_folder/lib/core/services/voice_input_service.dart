import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Speech-to-text for typing by voice: the phone's recognizer on Android and
/// iOS, the browser's (Chrome, Edge, Safari) on the web.
class VoiceInputService {
  final SpeechToText _speech = SpeechToText();
  bool? _available;
  VoidCallback? _onStopped;

  bool get isListening => _speech.isListening;

  /// Starts listening in [localeId] (e.g. 'fil_PH'). [onWords] gets the words
  /// heard so far in this session; [onStopped] runs once listening ends.
  /// Returns false when this device or browser has no speech recognition, or
  /// the microphone permission was refused.
  Future<bool> start({
    required String localeId,
    required void Function(String words) onWords,
    required VoidCallback onStopped,
  }) async {
    _onStopped = onStopped;
    _available ??= await _speech.initialize(
      onStatus: (status) {
        if (status == SpeechToText.doneStatus || status == SpeechToText.notListeningStatus) {
          _finish();
        }
      },
      onError: (error) {
        debugPrint('[VoiceInput] $error');
        _finish();
      },
    );
    if (_available != true) {
      _onStopped = null;
      return false;
    }
    await _speech.listen(
      onResult: (result) => onWords(result.recognizedWords),
      listenOptions: SpeechListenOptions(
        localeId: localeId,
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.dictation,
        listenFor: const Duration(minutes: 1),
        pauseFor: const Duration(seconds: 5),
      ),
    );
    return true;
  }

  Future<void> stop() async {
    await _speech.stop();
    _finish();
  }

  void _finish() {
    final callback = _onStopped;
    _onStopped = null;
    callback?.call();
  }
}
