/// Generic API response wrapper to normalize both `success` and `code/result` shapes.
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? timestamp;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.timestamp,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    final dynamic rawData = json['data'] ?? json['result'];
    return ApiResponse<T>(
      success: (json['success'] as bool?) ??
          ((json['code'] is num) ? json['code'] == 1000 : false),
      data: rawData != null ? fromJsonT(rawData) : null,
      message: json['message'] as String?,
      timestamp: json['timestamp']?.toString(),
    );
  }
}





