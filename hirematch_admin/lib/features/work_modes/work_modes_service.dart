import '../../core/constants/app_constants.dart';
import '../../core/network/api_client.dart';

class WorkMode {
  final int id;
  final String name;

  WorkMode({required this.id, required this.name});

  factory WorkMode.fromJson(Map<String, dynamic> json) =>
      WorkMode(id: json['id'], name: json['name'] ?? '');
}

class WorkModesService {
  static Future<List<WorkMode>> listAll() async {
    final json =
        await ApiClient.instance.get(
              ApiEndpoints.workModes,
              query: {'Page': 1, 'PageSize': 100, 'RetrieveTotalCount': false},
            )
            as Map<String, dynamic>;
    final rawList = (json['result'] as List?) ?? const [];
    return rawList
        .map((e) => WorkMode.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
