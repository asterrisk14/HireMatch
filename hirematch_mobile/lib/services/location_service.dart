import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class Country {
  final int id;
  final String name;
  Country({required this.id, required this.name});
  factory Country.fromJson(Map<String, dynamic> json) =>
      Country(id: json['id'] ?? 0, name: json['name'] ?? '');
}

class City {
  final int id;
  final String name;
  final int countryId;
  City({required this.id, required this.name, required this.countryId});
  factory City.fromJson(Map<String, dynamic> json) => City(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    countryId: json['countryId'] ?? 0,
  );
}

class LocationService {
  Future<List<Country>> getCountries() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/Countries?PageSize=100'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['result'] as List<dynamic>)
          .map((e) => Country.fromJson(e))
          .toList();
    }
    throw Exception('Failed to load countries');
  }

  Future<List<City>> getCities(int countryId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/Cities?CountryId=$countryId&PageSize=100'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['result'] as List<dynamic>)
          .map((e) => City.fromJson(e))
          .toList();
    }
    throw Exception('Failed to load cities');
  }
}