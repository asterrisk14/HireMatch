import '../../core/constants/app_constants.dart';
import '../../core/models/paged_result.dart';
import '../../core/network/api_client.dart';

class Country {
  final int id;
  final String name;

  Country({required this.id, required this.name});

  factory Country.fromJson(Map<String, dynamic> json) =>
      Country(id: json['id'], name: json['name'] ?? '');

  Map<String, dynamic> toJson() => {'name': name};
}

class CountriesService {
  static Future<PagedResult<Country>> list({
    String? search,
    int page = 1,
    int pageSize = 10,
  }) async {
    final json =
        await ApiClient.instance.get(
              ApiEndpoints.countries,
              query: {
                if (search != null && search.isNotEmpty) 'Name': search,
                'Page': page,
                'PageSize': pageSize,
                'RetrieveTotalCount': true,
              },
            )
            as Map<String, dynamic>;

    return PagedResult.fromJson(json, (e) => Country.fromJson(e));
  }

  static Future<List<Country>> listAll() async {
    final result = await list(page: 1, pageSize: 100);
    return result.result;
  }

  static Future<Country> create(String name) async {
    final json =
        await ApiClient.instance.post(ApiEndpoints.countries, body: {'name': name})
            as Map<String, dynamic>;
    return Country.fromJson(json);
  }

  static Future<Country> update(int id, String name) async {
    final json =
        await ApiClient.instance.put(
              '${ApiEndpoints.countries}/$id',
              body: {'name': name},
            )
            as Map<String, dynamic>;
    return Country.fromJson(json);
  }

  static Future<void> delete(int id) async {
    await ApiClient.instance.delete('${ApiEndpoints.countries}/$id');
  }
}
