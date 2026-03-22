using MagicEnglishAPI.Models;

namespace MagicEnglishAPI.Services;

/// <summary>
/// Interface for integration with Ollama AI API
/// </summary>
public interface IOllamaService
{
    /// <summary>
    /// Get vocabulary enrichment from Ollama API
    /// </summary>
    Task<OllamaVocabularyResponse?> EnrichVocabularyAsync(string word, CancellationToken cancellationToken = default);

    /// <summary>
    /// Check grammar using Ollama API
    /// </summary>
    Task<OllamaGrammarResponse?> CheckGrammarAsync(string text, CancellationToken cancellationToken = default);

    /// <summary>
    /// Get advanced analysis for a user from Ollama API
    /// </summary>
    Task<OllamaAdvancedAnalysisResponse?> GetAdvancedAnalysisAsync(int userId, string model, string prompt, CancellationToken cancellationToken = default);
}

public class OllamaVocabularyResponse
{
    public string Word { get; set; } = string.Empty;
    public string IPA { get; set; } = string.Empty;
    public string Meaning { get; set; } = string.Empty;
    public string PartOfSpeech { get; set; } = string.Empty;
    public string Example { get; set; } = string.Empty;
    public string CEFRLevel { get; set; } = string.Empty;
}

public class OllamaGrammarResponse
{
    public double Score { get; set; }
    public List<GrammarErrorDetail> Errors { get; set; } = new();
    public List<string> Suggestions { get; set; } = new();
}

public class GrammarErrorDetail
{
    public string Type { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public int Position { get; set; }
    public string SuggestedFix { get; set; } = string.Empty;
}

public class OllamaAdvancedAnalysisResponse
{
    public string Details { get; set; } = string.Empty;
    public List<string> Recommendations { get; set; } = new();
}
