namespace MagicEnglishAPI.DTOs;

/// <summary>
/// DTO for vocabulary operations
/// </summary>
public class AddVocabularyDto
{
    public string Word { get; set; } = string.Empty;
}

public class VocabularyDto
{
    public int Id { get; set; }
    public string Word { get; set; } = string.Empty;
    public string IPA { get; set; } = string.Empty;
    public string Meaning { get; set; } = string.Empty;
    public string PartOfSpeech { get; set; } = string.Empty;
    public string Example { get; set; } = string.Empty;
    public string CEFRLevel { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
    public DateTime? LastReviewedAt { get; set; }
    public int ReviewCount { get; set; }
}

public class VocabularyStatisticsDto
{
    public int TotalWords { get; set; }
    public Dictionary<string, int> PartOfSpeechDistribution { get; set; } = new();
    public Dictionary<string, int> CEFRLevelDistribution { get; set; } = new();
}
