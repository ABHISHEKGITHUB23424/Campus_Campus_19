import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api_client.dart';
import '../data/management_api.dart';
import '../models/department.dart';
import '../models/batch.dart';
import '../models/management_stats.dart';

// Provider for Management API
final managementApiProvider = Provider<ManagementApi>((ref) {
  final apiClient = ApiClient.getInstance();
  return ManagementApi(apiClient.dio);
});

// Provider for departments list
final departmentsProvider = FutureProvider.autoDispose<List<Department>>((
  ref,
) async {
  final api = ref.watch(managementApiProvider);
  return api.getDepartments();
});

// Provider for batches list
final batchesProvider = FutureProvider.autoDispose<List<Batch>>((ref) async {
  final api = ref.watch(managementApiProvider);
  return api.getBatches();
});

// Provider for management statistics
final managementStatsProvider = FutureProvider.autoDispose<ManagementStats>((
  ref,
) async {
  final api = ref.watch(managementApiProvider);
  return api.getStats();
});
