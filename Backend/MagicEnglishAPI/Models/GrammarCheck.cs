namespace MagicEnglishAPI.Models;

/// <summary>
/// Represents a grammar check performed by the user
/// </summary>
public class GrammarCheck
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string OriginalText { get; set; } = string.Empty;
    public double Score { get; set; } // 0-10
    public string Errors { get; set; } = string.Empty; // JSON format array of errors
    public string Suggestions { get; set; } = string.Empty; // JSON format array of suggestions
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation property
    public User? User { get; set; }
}
