import '../../core/constants/app_constants.dart';
import '../../core/models/paged_result.dart';
import '../../core/network/api_client.dart';

class Skill {
  final int id;
  final String name;

  Skill({required this.id, required this.name});

  factory Skill.fromJson(Map<String, dynamic> json) =>
      Skill(id: json['id'], name: json['name'] ?? '');

  Map<String, dynamic> toJson() => {'name': name};
}

class SkillsService {
  static Future<List<Skill>> listAll() async {
    final result = await list(page: 1, pageSize: 100);
    return result.result;
  }

  static Future<PagedResult<Skill>> list({
    String? search,
    int page = 1,
    int pageSize = 10,
  }) async {
    final json =
        await ApiClient.instance.get(
              ApiEndpoints.skills,
              query: {
                if (search != null && search.isNotEmpty) 'Name': search,
                'Page': page,
                'PageSize': pageSize,
                'RetrieveTotalCount': true,
              },
            )
            as Map<String, dynamic>;

    return PagedResult.fromJson(json, (e) => Skill.fromJson(e));
  }

  static Future<Skill> create(String name) async {
    final json =
        await ApiClient.instance.post(ApiEndpoints.skills, body: {'name': name})
            as Map<String, dynamic>;
    return Skill.fromJson(json);
  }

  static Future<Skill> update(int id, String name) async {
    final json =
        await ApiClient.instance.put(
              '${ApiEndpoints.skills}/$id',
              body: {'name': name},
            )
            as Map<String, dynamic>;
    return Skill.fromJson(json);
  }

  static Future<void> delete(int id) async {
    await ApiClient.instance.delete('${ApiEndpoints.skills}/$id');
  }
}
