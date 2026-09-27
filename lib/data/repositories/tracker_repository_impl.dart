import '../../domain/entities/tracker_data.dart';
import '../../domain/repositories/tracker_repository.dart';
import '../datasources/local_storage_datasource.dart';
import '../models/tracker_model.dart';

class TrackerRepositoryImpl implements TrackerRepository {
  const TrackerRepositoryImpl(this.dataSource);

  final LocalStorageDataSource dataSource;

  @override
  Future<TrackerData> load() => dataSource.load();

  @override
  Future<void> save(TrackerData data) {
    return dataSource.save(
      TrackerModel(
        nickname: data.nickname,
        activities: data.activities,
        completions: data.completions,
        themeMode: data.themeMode,
      ),
    );
  }
}
