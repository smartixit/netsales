class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final List<dynamic>? errors;

  final String? nextCursor;
  final String? prevCursor;
  final Map<String, dynamic>? meta;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
    this.nextCursor,
    this.prevCursor,
    this.meta,
  });

  /// Factory to handle generic data parsing.
  /// [fromJsonT] is a callback that defines how to parse the 'data' field.
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    final metaMap = json['meta'] is Map<String, dynamic>
        ? json['meta'] as Map<String, dynamic>
        : (json['meta'] is Map
              ? Map<String, dynamic>.from(json['meta'] as Map)
              : null);

    final nextCur =
        json['next_cursor']?.toString() ?? metaMap?['next_cursor']?.toString();
    final prevCur =
        json['prev_cursor']?.toString() ?? metaMap?['prev_cursor']?.toString();

    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      errors: json['errors'],
      nextCursor: nextCur,
      prevCursor: prevCur,
      meta: metaMap,
    );
  }

  /// Helper for empty or simple responses where data is null
  factory ApiResponse.fromSimpleJson(Map<String, dynamic> json) {
    final metaMap = json['meta'] is Map<String, dynamic>
        ? json['meta'] as Map<String, dynamic>
        : (json['meta'] is Map
              ? Map<String, dynamic>.from(json['meta'] as Map)
              : null);

    final nextCur =
        json['next_cursor']?.toString() ?? metaMap?['next_cursor']?.toString();
    final prevCur =
        json['prev_cursor']?.toString() ?? metaMap?['prev_cursor']?.toString();

    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: null,
      errors: _parseErrors(json['errors']),
      nextCursor: nextCur,
      prevCursor: prevCur,
      meta: metaMap,
    );
  }

  static List<dynamic>? _parseErrors(dynamic errorsData) {
    if (errorsData == null) return null;
    if (errorsData is List) return errorsData;
    if (errorsData is Map) {
      List<dynamic> parsedErrors = [];
      for (var value in errorsData.values) {
        if (value is List) {
          parsedErrors.addAll(value);
        } else {
          parsedErrors.add(value);
        }
      }
      return parsedErrors;
    }
    return [errorsData];
  }
}
