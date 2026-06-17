import '../../core/constants/app_constants.dart';
import '../../core/models/paged_result.dart';
import '../../core/network/api_client.dart';

class EmploymentType {
  final int id;
  final String name;

  EmploymentType({required this.id, required this.name});

  factory EmploymentType.fromJson(Map<String, dynamic> json) =>
      EmploymentType(id: json['id'], name: json['name'] ?? '');

  Map<String, dynamic> toJson() => {'name': name};
}

class EmploymentTypesService {
  static Future<List<EmploymentType>> listAll() async {
    final result = await list(page: 1, pageSize: 100);
    return result.result;
  }

  static Future<PagedResult<EmploymentType>> list({
    String? search,
    int page = 1,
    int pageSize = 10,
  }) async {
    final json =
        await ApiClient.instance.get(
              ApiEndpoints.employmentTypes,
              query: {
                if (search != null && search.isNotEmpty) 'Name': search,
                'Page': page,
                'PageSize': pageSize,
                'RetrieveTotalCount': true,
              },
            )
            as Map<String, dynamic>;

    return PagedResult.fromJson(json, (e) => EmploymentType.fromJson(e));
  }

  static Future<EmploymentType> create(String name) async {
    final json =
        await ApiClient.instance.post(
              ApiEndpoints.employmentTypes,
              body: {'name': name},
            )
            as Map<String, dynamic>;
    return EmploymentType.fromJson(json);
  }

  static Future<EmploymentType> update(int id, String name) async {
    final json =
        await ApiClient.instance.put(
              '${ApiEndpoints.employmentTypes}/$id',
              body: {'name': name},
            )
            as Map<String, dynamic>;
    return EmploymentType.fromJson(json);
  }

  static Future<void> delete(int id) async {
    await ApiClient.instance.delete('${ApiEndpoints.employmentTypes}/$id');
  }
}
