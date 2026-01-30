namespace Backend.DTOs
{
    public class StatsResponse
    {
        public int TotalVocabularyCount { get; set; }
        public int CurrentStreak { get; set; }
        public int LongestStreak { get; set; }
        public DateTime LastActivityDate { get; set; }
        public List<AchievementDto> Achievements { get; set; } = new();
    }

    public class AchievementDto
    {
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public bool Unlocked { get; set; }
        public int RequiredDays { get; set; }
    }

    public class WordTypeDistributionResponse
    {
        public string WordType { get; set; } = string.Empty;
        public int Count { get; set; }
    }

    public class CEFRLevelDistributionResponse
    {
        public string Level { get; set; } = string.Empty;
        public int Count { get; set; }
    }

    public class DashboardResponse
    {
        public StatsResponse Stats { get; set; } = new();
        public List<WordTypeDistributionResponse> WordTypeDistribution { get; set; } = new();
        public List<CEFRLevelDistributionResponse> CEFRDistribution { get; set; } = new();
    }
}
