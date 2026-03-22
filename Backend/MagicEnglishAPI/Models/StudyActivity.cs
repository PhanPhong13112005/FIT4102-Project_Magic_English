namespace MagicEnglishAPI.Models;

/// <summary>
/// Represents a study activity (vocabulary addition or grammar check)
/// </summary>
public class StudyActivity
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public ActivityType ActivityType { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation property
    public User? User { get; set; }
}

public enum ActivityType
{
    Vocabulary = 0,
    Grammar = 1
}
