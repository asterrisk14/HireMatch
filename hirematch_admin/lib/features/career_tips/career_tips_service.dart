import '../../core/constants/app_constants.dart';
import '../../core/models/paged_result.dart';
import '../../core/network/api_client.dart';

class CareerTip {
  final int id;
  final String title;
  final String content;
  final String icon;
  final DateTime createdAt;

  CareerTip({
    required this.id,
    required this.title,
    required this.content,
    required this.icon,
    required this.createdAt,
  });

  factory CareerTip.fromJson(Map<String, dynamic> json) => CareerTip(
        id: json['id'],
        title: json['title'] ?? '',
        content: json['content'] ?? '',
        icon: json['icon'] ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'].toString())
            : DateTime.now(),
      );
}

class CareerTipsService {
  static Future<PagedResult<CareerTip>> list({
    String? search,
    int page = 1,
    int pageSize = 10,
  }) async {
    final json =
        await ApiClient.instance.get(
              ApiEndpoints.careerTips,
              query: {
                if (search != null && search.isNotEmpty) 'Title': search,
                'Page': page,
                'PageSize': pageSize,
                'RetrieveTotalCount': true,
              },
            )
            as Map<String, dynamic>;

    return PagedResult.fromJson(json, (e) => CareerTip.fromJson(e));
  }

  static Future<CareerTip> create(
    String title,
    String content,
    String icon,
  ) async {
    final json =
        await ApiClient.instance.post(
              ApiEndpoints.careerTips,
              body: {'title': title, 'content': content, 'icon': icon},
            )
            as Map<String, dynamic>;
    return CareerTip.fromJson(json);
  }

  static Future<CareerTip> update(
    int id,
    String title,
    String content,
    String icon,
  ) async {
    final json =
        await ApiClient.instance.put(
              '${ApiEndpoints.careerTips}/$id',
              body: {'title': title, 'content': content, 'icon': icon},
            )
            as Map<String, dynamic>;
    return CareerTip.fromJson(json);
  }

  static Future<void> delete(int id) async {
    await ApiClient.instance.delete('${ApiEndpoints.careerTips}/$id');
  }
}
