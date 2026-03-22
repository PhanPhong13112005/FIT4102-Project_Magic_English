namespace MagicEnglishAPI.DTOs;

/// <summary>
/// DTO for grammar check operations
/// </summary>
public class GrammarCheckRequestDto
{
    public string Text { get; set; } = string.Empty;
}

public class GrammarCheckResponseDto
{
    public int Id { get; set; }
    public string OriginalText { get; set; } = string.Empty;
    public double Score { get; set; }
    public List<GrammarErrorDto> Errors { get; set; } = new();
    public List<string> Suggestions { get; set; } = new();
    public DateTime CreatedAt { get; set; }
}

public class GrammarErrorDto
{
    public string Type { get; set; } = string.Empty; // Grammar, Spelling, Style
    public string Description { get; set; } = string.Empty;
    public int Position { get; set; }
    public string SuggestedFix { get; set; } = string.Empty;
}
