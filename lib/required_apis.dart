final class RequiredReasonApi {
  const RequiredReasonApi({
    required this.requiredReasonApi,
    required this.url,
    required this.description,
    required this.key,
    required this.relevantApis,
    required this.reasons,
  });

  factory RequiredReasonApi.fromJson(Map<String, dynamic> json) {
    return RequiredReasonApi(
      requiredReasonApi: json['required_reason_api'] as String,
      url: json['url'] as String,
      description: json['description'] as String,
      key: json['key'] as String,
      relevantApis: List<String>.from(json['relevantApis'] as List<dynamic>),
      reasons:
          Map<String, String>.from(json['reasons'] as Map<String, dynamic>),
    );
  }

  final String requiredReasonApi;
  final String url;
  final String description;
  final String key;
  final List<String> relevantApis;
  final Map<String, String> reasons;
}
