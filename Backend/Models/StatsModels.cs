namespace Backend.Models
{
    public class UserStats
    {
        public int Id { get; set; }
        public int TotalVocabularyCount { get; set; }
        public int CurrentStreak { get; set; }
        public int LongestStreak { get; set; }
        public DateTime LastActivityDate { get; set; } = DateTime.UtcNow;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        // Foreign key
        public int UserId { get; set; }
        public virtual User? User { get; set; }
    }

    public class DailyActivity
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public DateTime ActivityDate { get; set; }
        public int VocabularyAdded { get; set; }
        public int WritingSubmissions { get; set; }
        public bool IsLearningDay { get; set; } // true if user did any activity on this day

        // Foreign key
        public virtual User? User { get; set; }
    }

    public class WordTypeDistribution
    {
        public string WordType { get; set; } = string.Empty;
        public int Count { get; set; }
    }

    public class CEFRLevelDistribution
    {
        public string Level { get; set; } = string.Empty; // A1, A2, B1, B2, C1, C2
        public int Count { get; set; }
    }
}
