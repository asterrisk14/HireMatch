import '../../core/constants/app_constants.dart';
import '../../core/models/paged_result.dart';
import '../../core/network/api_client.dart';

class ApplicationStatus {
  final int id;
  final String name;

  ApplicationStatus({required this.id, required this.name});

  factory ApplicationStatus.fromJson(Map<String, dynamic> json) =>
      ApplicationStatus(id: json['id'], name: json['name'] ?? '');

  Map<String, dynamic> toJson() => {'name': name};
}

class ApplicationStatusesService {
  static Future<List<ApplicationStatus>> listAll() async {
    final result = await list(page: 1, pageSize: 100);
    return result.result;
  }

  static Future<PagedResult<ApplicationStatus>> list({
    String? search,
    int page = 1,
    int pageSize = 10,
  }) async {
    final json =
        await ApiClient.instance.get(
              ApiEndpoints.applicationStatuses,
              query: {
                if (search != null && search.isNotEmpty) 'Name': search,
                'Page': page,
                'PageSize': pageSize,
                'RetrieveTotalCount': true,
              },
            )
            as Map<String, dynamic>;

    return PagedResult.fromJson(json, (e) => ApplicationStatus.fromJson(e));
  }

  static Future<ApplicationStatus> create(String name) async {
    final json =
        await ApiClient.instance.post(
              ApiEndpoints.applicationStatuses,
              body: {'name': name},
            )
            as Map<String, dynamic>;
    return ApplicationStatus.fromJson(json);
  }

  static Future<ApplicationStatus> update(int id, String name) async {
    final json =
        await ApiClient.instance.put(
              '${ApiEndpoints.applicationStatuses}/$id',
              body: {'name': name},
            )
            as Map<String, dynamic>;
    return ApplicationStatus.fromJson(json);
  }

  static Future<void> delete(int id) async {
    await ApiClient.instance.delete('${ApiEndpoints.applicationStatuses}/$id');
  }
}
