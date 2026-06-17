import '../../core/constants/app_constants.dart';
import '../../core/models/paged_result.dart';
import '../../core/network/api_client.dart';

class Company {
  final int id;
  final String name;
  final String address;
  final int? cityId;
  final String cityName;
  final String registrationNumber;
  final String? description;
  final String? website;
  final String? logoUrl;
  final DateTime createdAt;

  Company({
    required this.id,
    required this.name,
    required this.address,
    required this.cityId,
    required this.cityName,
    required this.registrationNumber,
    this.description,
    this.website,
    this.logoUrl,
    required this.createdAt,
  });

  factory Company.fromJson(Map<String, dynamic> json) => Company(
        id: json['id'],
        name: json['name'] ?? '',
        address: json['address'] ?? '',
        cityId: json['cityId'],
        cityName: json['cityName'] ?? '',
        registrationNumber: json['registrationNumber'] ?? '',
        description: json['description'],
        website: json['website'],
        logoUrl: json['logoUrl'],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'].toString())
            : DateTime.now(),
      );
}

class CompaniesService {
  static Future<List<Company>> listAll() async {
    final result = await list(page: 1, pageSize: 100);
    return result.result;
  }

  static Future<PagedResult<Company>> list({
    String? search,
    int page = 1,
    int pageSize = 10,
  }) async {
    final json =
        await ApiClient.instance.get(
              ApiEndpoints.companies,
              query: {
                if (search != null && search.isNotEmpty) 'Name': search,
                'Page': page,
                'PageSize': pageSize,
                'RetrieveTotalCount': true,
              },
            )
            as Map<String, dynamic>;

    return PagedResult.fromJson(json, (e) => Company.fromJson(e));
  }

  static Map<String, dynamic> _body({
    required String name,
    required String address,
    required int cityId,
    required String registrationNumber,
    String? description,
    String? website,
  }) {
    return {
      'name': name,
      'address': address,
      'cityId': cityId,
      'registrationNumber': registrationNumber,
      'description': description,
      'website': website,
    };
  }

  static Future<Company> create({
    required String name,
    required String address,
    required int cityId,
    required String registrationNumber,
    String? description,
    String? website,
  }) async {
    final json =
        await ApiClient.instance.post(
              ApiEndpoints.companies,
              body: _body(
                name: name,
                address: address,
                cityId: cityId,
                registrationNumber: registrationNumber,
                description: description,
                website: website,
              ),
            )
            as Map<String, dynamic>;
    return Company.fromJson(json);
  }

  static Future<Company> update({
    required int id,
    required String name,
    required String address,
    required int cityId,
    required String registrationNumber,
    String? description,
    String? website,
  }) async {
    final json =
        await ApiClient.instance.put(
              '${ApiEndpoints.companies}/$id',
              body: _body(
                name: name,
                address: address,
                cityId: cityId,
                registrationNumber: registrationNumber,
                description: description,
                website: website,
              ),
            )
            as Map<String, dynamic>;
    return Company.fromJson(json);
  }

  static Future<void> delete(int id) async {
    await ApiClient.instance.delete('${ApiEndpoints.companies}/$id');
  }
}
