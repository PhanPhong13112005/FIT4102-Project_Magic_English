namespace MagicEnglishAPI.Models;

/// <summary>
/// Represents a user in the system
/// </summary>
public class User
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation properties
    public ICollection<Vocabulary> Vocabularies { get; set; } = new List<Vocabulary>();
    public ICollection<GrammarCheck> GrammarChecks { get; set; } = new List<GrammarCheck>();
    public ICollection<StudyActivity> StudyActivities { get; set; } = new List<StudyActivity>();
    public Streak? Streak { get; set; }
}
