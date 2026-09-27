import '../entities/tracker_data.dart';

abstract class TrackerRepository {
  Future<TrackerData> load();
  Future<void> save(TrackerData data);
}
