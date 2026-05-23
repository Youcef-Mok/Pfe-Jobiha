import 'dart:async';

/// Broadcast stream that the API interceptor uses to signal a forced logout.
/// AuthNotifier subscribes and calls logout() when it fires.
class SessionEventBus {
  SessionEventBus._();

  static final _controller = StreamController<void>.broadcast();

  static Stream<void> get stream => _controller.stream;

  static void forceLogout() => _controller.add(null);
}
