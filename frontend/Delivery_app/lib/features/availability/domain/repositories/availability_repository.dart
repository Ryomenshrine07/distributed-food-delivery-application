import '../../../../core/error/result.dart';

abstract class AvailabilityRepository {
  Future<Result<void>> goOnline();
  Future<Result<void>> goOffline();
}
