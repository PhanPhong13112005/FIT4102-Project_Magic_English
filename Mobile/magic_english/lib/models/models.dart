/// Data models for Magic English App
/// Mirrors the backend DTOs

class User {
  final int id;
  final String name;
  final String email;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class Vocabulary {
  final int id;
  final String word;
  final String ipa;
  final String meaning;
  final String partOfSpeech;
  final String example;
  final String cefrLevel;
  final DateTime createdAt;
  final DateTime? lastReviewedAt;
  final int reviewCount;

  Vocabulary({
    required this.id,
    required this.word,
    required this.ipa,
    required this.meaning,
    required this.partOfSpeech,
    required this.example,
    required this.cefrLevel,
    required this.createdAt,
    this.lastReviewedAt,
    required this.reviewCount,
  });

  factory Vocabulary.fromJson(Map<String, dynamic> json) {
    return Vocabulary(
      id: json['id'] ?? 0,
      word: json['word'] ?? '',
      ipa: json['ipa'] ?? '',
      meaning: json['meaning'] ?? '',
      partOfSpeech: json['partOfSpeech'] ?? '',
      example: json['example'] ?? '',
      cefrLevel: json['cefrLevel'] ?? 'A1',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastReviewedAt: json['lastReviewedAt'] != null 
          ? DateTime.parse(json['lastReviewedAt']) 
          : null,
      reviewCount: json['reviewCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'ipa': ipa,
      'meaning': meaning,
      'partOfSpeech': partOfSpeech,
      'example': example,
      'cefrLevel': cefrLevel,
      'createdAt': createdAt.toIso8601String(),
      'lastReviewedAt': lastReviewedAt?.toIso8601String(),
      'reviewCount': reviewCount,
    };
  }
}

class VocabularyStatistics {
  final int totalWords;
  final Map<String, int> partOfSpeechDistribution;
  final Map<String, int> cefrLevelDistribution;

  VocabularyStatistics({
    required this.totalWords,
    required this.partOfSpeechDistribution,
    required this.cefrLevelDistribution,
  });

  factory VocabularyStatistics.fromJson(Map<String, dynamic> json) {
    return VocabularyStatistics(
      totalWords: json['totalWords'] ?? 0,
      partOfSpeechDistribution: Map<String, int>.from(json['partOfSpeechDistribution'] ?? {}),
      cefrLevelDistribution: Map<String, int>.from(json['cefrLevelDistribution'] ?? {}),
    );
  }
}

class GrammarError {
  final String type;
  final String description;
  final int position;
  final String suggestedFix;

  GrammarError({
    required this.type,
    required this.description,
    required this.position,
    required this.suggestedFix,
  });

  factory GrammarError.fromJson(Map<String, dynamic> json) {
    return GrammarError(
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      position: json['position'] ?? 0,
      suggestedFix: json['suggestedFix'] ?? '',
    );
  }
}

class GrammarCheckResult {
  final int id;
  final String originalText;
  final double score;
  final List<GrammarError> errors;
  final List<String> suggestions;
  final DateTime createdAt;

  GrammarCheckResult({
    required this.id,
    required this.originalText,
    required this.score,
    required this.errors,
    required this.suggestions,
    required this.createdAt,
  });

  factory GrammarCheckResult.fromJson(Map<String, dynamic> json) {
    var errorsList = <GrammarError>[];
    if (json['errors'] != null) {
      errorsList = List<GrammarError>.from(
        (json['errors'] as List).map((e) => GrammarError.fromJson(e))
      );
    }

    var suggestionsList = <String>[];
    if (json['suggestions'] != null) {
      suggestionsList = List<String>.from(json['suggestions'] ?? []);
    }

    return GrammarCheckResult(
      id: json['id'] ?? 0,
      originalText: json['originalText'] ?? '',
      score: (json['score'] ?? 0).toDouble(),
      errors: errorsList,
      suggestions: suggestionsList,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class Streak {
  final int id;
  final int currentStreak;
  final int longestStreak;
  final DateTime lastStudyDate;
  final bool has3DaysBadge;
  final bool has7DaysBadge;
  final bool has30DaysBadge;

  Streak({
    required this.id,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastStudyDate,
    required this.has3DaysBadge,
    required this.has7DaysBadge,
    required this.has30DaysBadge,
  });

  factory Streak.fromJson(Map<String, dynamic> json) {
    return Streak(
      id: json['id'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastStudyDate: DateTime.parse(json['lastStudyDate'] ?? DateTime.now().toIso8601String()),
      has3DaysBadge: json['has3DaysBadge'] ?? false,
      has7DaysBadge: json['has7DaysBadge'] ?? false,
      has30DaysBadge: json['has30DaysBadge'] ?? false,
    );
  }
}

class DailyActivity {
  final DateTime date;
  final int vocabularyCount;
  final int grammarCount;
  final int totalCount;

  DailyActivity({
    required this.date,
    required this.vocabularyCount,
    required this.grammarCount,
    required this.totalCount,
  });

  factory DailyActivity.fromJson(Map<String, dynamic> json) {
    return DailyActivity(
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      vocabularyCount: json['vocabularyCount'] ?? 0,
      grammarCount: json['grammarCount'] ?? 0,
      totalCount: json['totalCount'] ?? 0,
    );
  }
}

class Dashboard {
  final int totalVocabularyLearned;
  final int currentStreak;
  final int todayActivityCount;
  final Streak streak;
  final VocabularyStatistics vocabularyStats;
  final List<DailyActivity> activityTrend;

  Dashboard({
    required this.totalVocabularyLearned,
    required this.currentStreak,
    required this.todayActivityCount,
    required this.streak,
    required this.vocabularyStats,
    required this.activityTrend,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    var trendList = <DailyActivity>[];
    if (json['activityTrend'] != null) {
      trendList = List<DailyActivity>.from(
        (json['activityTrend'] as List).map((e) => DailyActivity.fromJson(e))
      );
    }

    return Dashboard(
      totalVocabularyLearned: json['totalVocabularyLearned'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      todayActivityCount: json['todayActivityCount'] ?? 0,
      streak: Streak.fromJson(json['streak'] ?? {}),
      vocabularyStats: VocabularyStatistics.fromJson(json['vocabularyStats'] ?? {}),
      activityTrend: trendList,
    );
  }
}
