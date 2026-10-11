/// Base type for failures returned from data and domain layers.
///
/// Widgets and notifiers map a [Failure] to user-facing copy. Keep the
/// hierarchy small so tests can assert against exact subclasses.
sealed class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType($message)';
}

/// Network is unavailable or timed out.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No connection']);
}

/// Input failed validation before reaching the backend.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Authentication is missing or expired.
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication required']);
}

/// The Firebase backend returned an error we did not categorize.
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// The requested item was not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found']);
}

/// Catch-all for unexpected programmer errors. Should be rare in production.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong']);
}
