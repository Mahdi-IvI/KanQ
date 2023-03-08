class TaskTimer {
  final Stopwatch _stopwatch = Stopwatch();


  bool get isActive => _stopwatch.isRunning;

  void start() {
    _stopwatch.start();
  }

  void stop() {
    _stopwatch.stop();
  }

  Duration get elapsed => _stopwatch.elapsed;
}
