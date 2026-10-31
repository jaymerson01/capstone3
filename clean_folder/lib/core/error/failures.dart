abstract class Failure {
  final String message;

  /// Machine-readable reason (e.g. a FirebaseAuthException code) so the UI
  /// can show a translated message; [message] stays the English fallback.
  final String? code;

  const Failure(this.message, {this.code});
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}
