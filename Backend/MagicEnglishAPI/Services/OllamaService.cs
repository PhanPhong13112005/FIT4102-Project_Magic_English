using System.Net.Http.Json;
using System.Text.Json;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace MagicEnglishAPI.Services;

/// <summary>
/// Service for integrating with Ollama Cloud API
/// </summary>
public class OllamaService : IOllamaService
{
    private readonly HttpClient _httpClient;
    private readonly IConfiguration _configuration;
    private readonly ILogger<OllamaService> _logger;

    public OllamaService(HttpClient httpClient, IConfiguration configuration, ILogger<OllamaService> logger)
    {
        _httpClient = httpClient;
        _configuration = configuration;
        _logger = logger;
        
        // Configure HTTP client
        var baseUrl = _configuration["OllamaApi:BaseUrl"];
        var apiKey = _configuration["OllamaApi:ApiKey"];
        
        _httpClient.BaseAddress = new Uri(baseUrl ?? "https://api.ollamcloud.com/api");
        _httpClient.DefaultRequestHeaders.Add("Authorization", $"Bearer {apiKey}");
        _httpClient.Timeout = TimeSpan.FromSeconds(_configuration.GetValue<int>("OllamaApi:TimeoutSeconds", 30));
    }

    /// <summary>
    /// Enriches vocabulary by calling Ollama API with the word
    /// </summary>
    public async Task<OllamaVocabularyResponse?> EnrichVocabularyAsync(string word, CancellationToken cancellationToken = default)
    {
        try
        {
            _logger.LogInformation("Enriching vocabulary for word: {Word}", word);

            var prompt = GenerateVocabularyPrompt(word);
            var request = new OllamaRequest
            {
                Model = _configuration["OllamaApi:VocabularyModel"] ?? "llama2:13b",
                Prompt = prompt,
                Stream = false
            };

            var response = await _httpClient.PostAsJsonAsync("/generate", request, cancellationToken);
            response.EnsureSuccessStatusCode();

            var contentString = await response.Content.ReadAsStringAsync(cancellationToken);
            var content = JsonSerializer.Deserialize<OllamaGenerateResponse>(contentString);
            
            var parsedResponse = ParseVocabularyResponse(content?.Response ?? "");
            _logger.LogInformation("Successfully enriched vocabulary for word: {Word}", word);
            
            return parsedResponse;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error enriching vocabulary for word: {Word}", word);
            return null;
        }
    }

    /// <summary>
    /// Checks grammar by calling Ollama API
    /// </summary>
    public async Task<OllamaGrammarResponse?> CheckGrammarAsync(string text, CancellationToken cancellationToken = default)
    {
        try
        {
            _logger.LogInformation("Checking grammar for text length: {TextLength}", text.Length);

            var prompt = GenerateGrammarPrompt(text);
            var request = new OllamaRequest
            {
                Model = _configuration["OllamaApi:GrammarModel"] ?? "llama2:13b",
                Prompt = prompt,
                Stream = false
            };

            var response = await _httpClient.PostAsJsonAsync("/generate", request, cancellationToken);
            response.EnsureSuccessStatusCode();

            var contentString = await response.Content.ReadAsStringAsync(cancellationToken);
            var content = JsonSerializer.Deserialize<OllamaGenerateResponse>(contentString);
            
            var parsedResponse = ParseGrammarResponse(content?.Response ?? "");
            _logger.LogInformation("Successfully checked grammar");
            
            return parsedResponse;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error checking grammar");
            return null;
        }
    }

    /// <summary>
    /// Gets advanced analysis for a user by calling Ollama API
    /// </summary>
    public async Task<OllamaAdvancedAnalysisResponse?> GetAdvancedAnalysisAsync(int userId, string model, string prompt, CancellationToken cancellationToken = default)
    {
        try
        {
            _logger.LogInformation("Getting advanced analysis for user: {UserId}", userId);

            var request = new OllamaRequest
            {
                Model = model,
                Prompt = prompt,
                Stream = false
            };

            var response = await _httpClient.PostAsJsonAsync("/generate", request, cancellationToken);
            response.EnsureSuccessStatusCode();

            var contentString = await response.Content.ReadAsStringAsync(cancellationToken);
            var content = JsonSerializer.Deserialize<OllamaGenerateResponse>(contentString);

            return new OllamaAdvancedAnalysisResponse
            {
                Details = content?.Response ?? string.Empty,
                Recommendations = ParseRecommendations(content?.Response ?? string.Empty)
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting advanced analysis for user: {UserId}", userId);
            return null;
        }
    }

    private List<string> ParseRecommendations(string response)
    {
        // Implement parsing logic to extract recommendations from the response
        return new List<string> { response };
    }

    /// <summary>
    /// Generates the prompt for vocabulary enrichment
    /// </summary>
    private string GenerateVocabularyPrompt(string word)
    {
        return $@"You are an expert English teacher helping students learn vocabulary. 

Provide detailed vocabulary information for the English word: ""{word}"".

Return ONLY a JSON object with these exact fields (no markdown, no code blocks):
{{
  ""word"": ""{word}"",
  ""ipa"": """",
  ""meaning"": """",
  ""partOfSpeech"": """",
  ""example"": """",
  ""cefrLevel"": """"
}}

Fill each field with accurate and detailed information:
- ipa: Provide the International Phonetic Alphabet (IPA) pronunciation of the word.
- meaning: Provide a clear and concise Vietnamese translation of the word.
- partOfSpeech: Specify the part of speech (e.g., noun, verb, adjective, adverb, preposition, etc.).
- example: Provide a meaningful example sentence using the word in context.
- cefrLevel: Specify the CEFR level (A1, A2, B1, B2, C1, C2) that corresponds to the word's difficulty level.

Ensure the JSON object is properly formatted and contains no additional text or formatting. Return only the JSON object.";
    }

    /// <summary>
    /// Generates the prompt for grammar checking
    /// </summary>
    private string GenerateGrammarPrompt(string text)
    {
        return $@"You are an expert English grammar checker. Analyze the following text for grammar, spelling, and style errors.

Text to check: ""{text}""

Return ONLY a JSON object with these exact fields (no markdown, no code blocks):
{{
  ""score"": 0,
  ""errors"": [
    {{
      ""type"": """",
      ""description"": """",
      ""position"": 0,
      ""suggestedFix"": """"
    }}
  ],
  ""suggestions"": []
}}

Guidelines:
- score: A number from 0 to 10 (10 = perfect English)
- errors: Array of grammar, spelling, or style errors found
  - type: 'Grammar', 'Spelling', or 'Style'
  - description: Description of the error
  - position: Character position where error occurs
  - suggestedFix: How to correct the error
- suggestions: Array of general improvement suggestions

If the text is correct, return score 10 with empty errors and suggestions arrays.

Return only the JSON object, nothing else.";
    }

    /// <summary>
    /// Parses the Ollama response into a vocabulary object
    /// </summary>
    private OllamaVocabularyResponse? ParseVocabularyResponse(string response)
    {
        try
        {
            // Log the raw response for debugging
            _logger.LogInformation("Raw API response: {Response}", response);

            // Clean the response - remove any markdown or extra formatting
            var cleanedResponse = response.Trim();
            if (cleanedResponse.StartsWith("```json"))
            {
                cleanedResponse = cleanedResponse["```json".Length..];
            }
            if (cleanedResponse.StartsWith("```"))
            {
                cleanedResponse = cleanedResponse[3..];
            }
            if (cleanedResponse.EndsWith("```"))
            {
                cleanedResponse = cleanedResponse[..^3];
            }

            var jsonElement = JsonSerializer.Deserialize<JsonElement>(cleanedResponse);
            
            return new OllamaVocabularyResponse
            {
                Word = jsonElement.TryGetProperty("word", out var word) ? word.GetString() ?? "" : "",
                IPA = jsonElement.TryGetProperty("ipa", out var ipa) ? ipa.GetString() ?? "" : "",
                Meaning = jsonElement.TryGetProperty("meaning", out var meaning) ? meaning.GetString() ?? "" : "",
                PartOfSpeech = jsonElement.TryGetProperty("partOfSpeech", out var pos) ? pos.GetString() ?? "" : "",
                Example = jsonElement.TryGetProperty("example", out var example) ? example.GetString() ?? "" : "",
                CEFRLevel = jsonElement.TryGetProperty("cefrLevel", out var level) ? level.GetString() ?? "A1" : "A1"
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error parsing vocabulary response");
            return null;
        }
    }

    /// <summary>
    /// Parses the Ollama response into a grammar check object
    /// </summary>
    private OllamaGrammarResponse? ParseGrammarResponse(string response)
    {
        try
        {
            // Clean the response
            var cleanedResponse = response.Trim();
            if (cleanedResponse.StartsWith("```json"))
            {
                cleanedResponse = cleanedResponse["```json".Length..];
            }
            if (cleanedResponse.StartsWith("```"))
            {
                cleanedResponse = cleanedResponse[3..];
            }
            if (cleanedResponse.EndsWith("```"))
            {
                cleanedResponse = cleanedResponse[..^3];
            }

            var jsonElement = JsonSerializer.Deserialize<JsonElement>(cleanedResponse);
            
            var errors = new List<GrammarErrorDetail>();
            if (jsonElement.TryGetProperty("errors", out var errorsArray))
            {
                foreach (var error in errorsArray.EnumerateArray())
                {
                    errors.Add(new GrammarErrorDetail
                    {
                        Type = error.TryGetProperty("type", out var type) ? type.GetString() ?? "" : "",
                        Description = error.TryGetProperty("description", out var desc) ? desc.GetString() ?? "" : "",
                        Position = error.TryGetProperty("position", out var pos) ? pos.GetInt32() : 0,
                        SuggestedFix = error.TryGetProperty("suggestedFix", out var fix) ? fix.GetString() ?? "" : ""
                    });
                }
            }

            var suggestions = new List<string>();
            if (jsonElement.TryGetProperty("suggestions", out var suggestionsArray))
            {
                foreach (var suggestion in suggestionsArray.EnumerateArray())
                {
                    if (suggestion.ValueKind == System.Text.Json.JsonValueKind.String)
                    {
                        suggestions.Add(suggestion.GetString() ?? "");
                    }
                }
            }

            return new OllamaGrammarResponse
            {
                Score = jsonElement.TryGetProperty("score", out var score) ? score.GetDouble() : 0,
                Errors = errors,
                Suggestions = suggestions
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error parsing grammar response");
            return null;
        }
    }

    /// <summary>
    /// Request model for Ollama API
    /// </summary>
    private class OllamaRequest
    {
        public string Model { get; set; } = string.Empty;
        public string Prompt { get; set; } = string.Empty;
        public bool Stream { get; set; } = false;
    }

    /// <summary>
    /// Response model from Ollama API
    /// </summary>
    private class OllamaGenerateResponse
    {
        public string Response { get; set; } = string.Empty;
    }
}
