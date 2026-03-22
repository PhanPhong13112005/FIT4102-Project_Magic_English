namespace MagicEnglishAPI.Models;

/// <summary>
/// Represents user's study streak and badges
/// </summary>
public class Streak
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int CurrentStreak { get; set; } = 0;
    public DateTime LastStudyDate { get; set; } = DateTime.UtcNow;
    public int LongestStreak { get; set; } = 0;
    public int Badge3Days { get; set; } = 0; // 0 = not earned, 1 = earned
    public int Badge7Days { get; set; } = 0;
    public int Badge30Days { get; set; } = 0;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    // Navigation property
    public User? User { get; set; }
}
