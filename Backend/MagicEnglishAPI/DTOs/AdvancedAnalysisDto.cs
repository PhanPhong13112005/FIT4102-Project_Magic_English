namespace MagicEnglishAPI.DTOs;

/// <summary>
/// DTO for advanced analysis response
/// </summary>
public class AdvancedAnalysisDto
{
    public int UserId { get; set; }
    public string AnalysisDetails { get; set; } = string.Empty;
    public List<string> Recommendations { get; set; } = new();
}