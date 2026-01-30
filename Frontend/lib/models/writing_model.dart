class WritingError {
  final int position;
  final String errorType;
  final String message;

  WritingError({
    required this.position,
    required this.errorType,
    required this.message,
  });

  factory WritingError.fromJson(Map<String, dynamic> json) {
    return WritingError(
      position: json['position'] as int,
      errorType: json['errorType'] as String,
      message: json['message'] as String,
    );
  }
}

class WritingSuggestion {
  final String current;
  final String suggested;
  final String reason;

  WritingSuggestion({
    required this.current,
    required this.suggested,
    required this.reason,
  });

  factory WritingSuggestion.fromJson(Map<String, dynamic> json) {
    return WritingSuggestion(
      current: json['current'] as String,
      suggested: json['suggested'] as String,
      reason: json['reason'] as String,
    );
  }
}

class WritingCheckResponse {
  final int score;
  final List<WritingError> errors;
  final List<WritingSuggestion> suggestions;

  WritingCheckResponse({
    required this.score,
    required this.errors,
    required this.suggestions,
  });

  factory WritingCheckResponse.fromJson(Map<String, dynamic> json) {
    return WritingCheckResponse(
      score: json['score'] as int,
      errors: (json['errors'] as List<dynamic>)
          .map((e) => WritingError.fromJson(e as Map<String, dynamic>))
          .toList(),
      suggestions: (json['suggestions'] as List<dynamic>)
          .map((s) => WritingSuggestion.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}
