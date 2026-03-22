namespace MagicEnglishAPI.DTOs;

/// <summary>
/// DTO for statistics and streak operations
/// </summary>
public class StreakDto
{
    public int Id { get; set; }
    public int CurrentStreak { get; set; }
    public int LongestStreak { get; set; }
    public DateTime LastStudyDate { get; set; }
    public bool Has3DaysBadge { get; set; }
    public bool Has7DaysBadge { get; set; }
    public bool Has30DaysBadge { get; set; }
}

public class DashboardDto
{
    public int TotalVocabularyLearned { get; set; }
    public int CurrentStreak { get; set; }
    public int TodayActivityCount { get; set; }
    public StreakDto Streak { get; set; } = new();
    public VocabularyStatisticsDto VocabularyStats { get; set; } = new();
    public List<DailyActivityDto> ActivityTrend { get; set; } = new();
}

public class DailyActivityDto
{
    public DateTime Date { get; set; }
    public int VocabularyCount { get; set; }
    public int GrammarCount { get; set; }
    public int TotalCount { get; set; }
}
