import '../../core/constants/app_constants.dart';
import '../../core/models/paged_result.dart';
import '../../core/network/api_client.dart';

class City {
  final int id;
  final String name;
  final int countryId;
  final String countryName;

  City({
    required this.id,
    required this.name,
    required this.countryId,
    required this.countryName,
  });

  factory City.fromJson(Map<String, dynamic> json) => City(
        id: json['id'],
        name: json['name'] ?? '',
        countryId: json['countryId'] ?? 0,
        countryName: json['countryName'] ?? '',
      );
}

class CitiesService {
  static Future<PagedResult<City>> list({
    int? countryId,
    int page = 1,
    int pageSize = 10,
  }) async {
    final json =
        await ApiClient.instance.get(
              ApiEndpoints.cities,
              query: {
                if (countryId != null) 'CountryId': countryId,
                'Page': page,
                'PageSize': pageSize,
                'RetrieveTotalCount': true,
              },
            )
            as Map<String, dynamic>;

    return PagedResult.fromJson(json, (e) => City.fromJson(e));
  }

  static Future<List<City>> listAll() async {
    final result = await list(page: 1, pageSize: 100);
    return result.result;
  }

  static Future<City> create(String name, int countryId) async {
    final json =
        await ApiClient.instance.post(
              ApiEndpoints.cities,
              body: {'name': name, 'countryId': countryId},
            )
            as Map<String, dynamic>;
    return City.fromJson(json);
  }

  static Future<City> update(int id, String name, int countryId) async {
    final json =
        await ApiClient.instance.put(
              '${ApiEndpoints.cities}/$id',
              body: {'name': name, 'countryId': countryId},
            )
            as Map<String, dynamic>;
    return City.fromJson(json);
  }

  static Future<void> delete(int id) async {
    await ApiClient.instance.delete('${ApiEndpoints.cities}/$id');
  }
}
