class Achievement {
  final String name;
  final String description;
  final bool unlocked;
  final int requiredDays;

  Achievement({
    required this.name,
    required this.description,
    required this.unlocked,
    required this.requiredDays,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      name: json['name'] as String,
      description: json['description'] as String,
      unlocked: json['unlocked'] as bool,
      requiredDays: json['requiredDays'] as int,
    );
  }
}

class StatsResponse {
  final int totalVocabularyCount;
  final int currentStreak;
  final int longestStreak;
  final DateTime lastActivityDate;
  final List<Achievement> achievements;

  StatsResponse({
    required this.totalVocabularyCount,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActivityDate,
    required this.achievements,
  });

  factory StatsResponse.fromJson(Map<String, dynamic> json) {
    return StatsResponse(
      totalVocabularyCount: json['totalVocabularyCount'] as int,
      currentStreak: json['currentStreak'] as int,
      longestStreak: json['longestStreak'] as int,
      lastActivityDate: DateTime.parse(json['lastActivityDate'] as String),
      achievements: (json['achievements'] as List<dynamic>)
          .map((a) => Achievement.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Distribution {
  final String label;
  final int count;

  Distribution({required this.label, required this.count});

  factory Distribution.fromJson(Map<String, dynamic> json) {
    return Distribution(
      label: json['wordType'] ?? json['level'] ?? '',
      count: json['count'] as int,
    );
  }
}

class DashboardResponse {
  final StatsResponse stats;
  final List<Distribution> wordTypeDistribution;
  final List<Distribution> cefrDistribution;

  DashboardResponse({
    required this.stats,
    required this.wordTypeDistribution,
    required this.cefrDistribution,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      stats: StatsResponse.fromJson(json['stats'] as Map<String, dynamic>),
      wordTypeDistribution: (json['wordTypeDistribution'] as List<dynamic>)
          .map((d) => Distribution.fromJson(d as Map<String, dynamic>))
          .toList(),
      cefrDistribution: (json['cefrDistribution'] as List<dynamic>)
          .map((d) => Distribution.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }
}
