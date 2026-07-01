abstract class BackgroundLocationRepository {
  void init();
  Future<void> startService();
  Future<void> stopService();
}
