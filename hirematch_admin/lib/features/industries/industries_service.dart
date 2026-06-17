import '../../core/constants/app_constants.dart';
import '../../core/models/paged_result.dart';
import '../../core/network/api_client.dart';

class Industry {
  final int id;
  final String name;

  Industry({required this.id, required this.name});

  factory Industry.fromJson(Map<String, dynamic> json) =>
      Industry(id: json['id'], name: json['name'] ?? '');

  Map<String, dynamic> toJson() => {'name': name};
}

class IndustriesService {
  static Future<List<Industry>> listAll() async {
    final result = await list(page: 1, pageSize: 100);
    return result.result;
  }

  static Future<PagedResult<Industry>> list({
    String? search,
    int page = 1,
    int pageSize = 10,
  }) async {
    final json =
        await ApiClient.instance.get(
              ApiEndpoints.industries,
              query: {
                if (search != null && search.isNotEmpty) 'Name': search,
                'Page': page,
                'PageSize': pageSize,
                'RetrieveTotalCount': true,
              },
            )
            as Map<String, dynamic>;

    return PagedResult.fromJson(json, (e) => Industry.fromJson(e));
  }

  static Future<Industry> create(String name) async {
    final json =
        await ApiClient.instance.post(ApiEndpoints.industries, body: {'name': name})
            as Map<String, dynamic>;
    return Industry.fromJson(json);
  }

  static Future<Industry> update(int id, String name) async {
    final json =
        await ApiClient.instance.put(
              '${ApiEndpoints.industries}/$id',
              body: {'name': name},
            )
            as Map<String, dynamic>;
    return Industry.fromJson(json);
  }

  static Future<void> delete(int id) async {
    await ApiClient.instance.delete('${ApiEndpoints.industries}/$id');
  }
}
