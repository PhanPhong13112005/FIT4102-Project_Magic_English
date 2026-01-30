class VocabularyModel {
  final int id;
  final String word;
  final String meaning;
  final String ipa;
  final String wordType;
  final String example;
  final String cefrLevel;
  final DateTime createdAt;

  VocabularyModel({
    required this.id,
    required this.word,
    required this.meaning,
    required this.ipa,
    required this.wordType,
    required this.example,
    required this.cefrLevel,
    required this.createdAt,
  });

  factory VocabularyModel.fromJson(Map<String, dynamic> json) {
    return VocabularyModel(
      id: json['id'] as int,
      word: json['word'] as String,
      meaning: json['meaning'] as String,
      ipa: json['ipa'] as String,
      wordType: json['wordType'] as String,
      example: json['example'] as String,
      cefrLevel: json['cefrLevel'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'meaning': meaning,
      'ipa': ipa,
      'wordType': wordType,
      'example': example,
      'cefrLevel': cefrLevel,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class VocabularyListResponse {
  final List<VocabularyModel> items;
  final int totalCount;

  VocabularyListResponse({required this.items, required this.totalCount});

  factory VocabularyListResponse.fromJson(Map<String, dynamic> json) {
    return VocabularyListResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => VocabularyModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int,
    );
  }
}
