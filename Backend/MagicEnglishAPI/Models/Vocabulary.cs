namespace MagicEnglishAPI.Models;

/// <summary>
/// Represents a vocabulary word in a user's notebook
/// </summary>
public class Vocabulary
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string Word { get; set; } = string.Empty;
    public string IPA { get; set; } = string.Empty;
    public string Meaning { get; set; } = string.Empty;
    public string PartOfSpeech { get; set; } = string.Empty; // noun, verb, adjective, etc.
    public string Example { get; set; } = string.Empty;
    public string CEFRLevel { get; set; } = "A1"; // A1, A2, B1, B2, C1, C2
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? LastReviewedAt { get; set; }
    public int ReviewCount { get; set; } = 0;

    // Navigation property
    public User? User { get; set; }
}
