class PagedResult<T> {
  final List<T> result;
  final int totalCount;

  PagedResult({required this.result, required this.totalCount});

  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final rawList = (json['result'] as List?) ?? const [];
    return PagedResult<T>(
      result:
          rawList.map((e) => fromJsonT(e as Map<String, dynamic>)).toList(),
      totalCount: json['totalCount'] ?? rawList.length,
    );
  }
}
