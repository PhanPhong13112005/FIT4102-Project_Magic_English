using System.Text;
using System.Text.Json;

namespace Backend.Services
{
    public interface IOllamaService
    {
        Task<VocabularyAIResponse> ExtractVocabularyAsync(string word);
        Task<WritingCheckAIResponse> CheckWritingAsync(string content);
    }

    public class OllamaService : IOllamaService
    {
        private readonly HttpClient _httpClient;
        private readonly IConfiguration _configuration;
        private readonly string _ollamaUrl;
        private readonly string _ollamaModel;

        public OllamaService(HttpClient httpClient, IConfiguration configuration)
        {
            _httpClient = httpClient;
            _configuration = configuration;
            _ollamaUrl = configuration["Ollama:Url"] ?? "http://localhost:11434";
            _ollamaModel = configuration["Ollama:Model"] ?? "llama2";
        }

        public async Task<VocabularyAIResponse> ExtractVocabularyAsync(string word)
        {
            try
            {
                string prompt = $@"Extract vocabulary information for the English word: '{word}'
                
                Please provide ONLY a JSON response (no markdown, no explanations) with this exact structure:
                {{
                    ""word"": ""{word}"",
                    ""meaning"": ""Vietnamese meaning"",
                    ""ipa"": ""IPA phonetic notation"",
                    ""wordType"": ""noun/verb/adjective/adverb/etc"",
                    ""example"": ""Example sentence using the word"",
                    ""cefrLevel"": ""A1/A2/B1/B2/C1/C2""
                }}";

                var response = await CallOllamaAsync(prompt);
                return ParseVocabularyResponse(response, word);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error in ExtractVocabularyAsync: {ex.Message}");
                // Return default response on error
                return new VocabularyAIResponse
                {
                    Word = word,
                    Meaning = "Unable to fetch meaning",
                    IPA = "",
                    WordType = "unknown",
                    Example = "",
                    CEFRLevel = "B1"
                };
            }
        }

        public async Task<WritingCheckAIResponse> CheckWritingAsync(string content)
        {
            try
            {
                string prompt = $@"Check the English text for grammar, spelling, and style issues:
                
                Text: ""{content}""
                
                Provide ONLY a JSON response (no markdown, no explanations) with this structure:
                {{
                    ""score"": 0-10,
                    ""errors"": [
                        {{
                            ""type"": ""grammar/spelling/style"",
                            ""message"": ""Error description"",
                            ""position"": 0
                        }}
                    ],
                    ""suggestions"": [
                        {{
                            ""current"": ""current phrase"",
                            ""suggested"": ""improved phrase"",
                            ""reason"": ""why this is better""
                        }}
                    ]
                }}";

                var response = await CallOllamaAsync(prompt);
                return ParseWritingCheckResponse(response);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error in CheckWritingAsync: {ex.Message}");
                // Return default response on error
                return new WritingCheckAIResponse
                {
                    Score = 5,
                    Errors = new(),
                    Suggestions = new()
                };
            }
        }

        private async Task<string> CallOllamaAsync(string prompt)
        {
            var requestBody = new
            {
                model = _ollamaModel,
                prompt = prompt,
                stream = false
            };

            var content = new StringContent(
                JsonSerializer.Serialize(requestBody),
                Encoding.UTF8,
                "application/json");

            var response = await _httpClient.PostAsync($"{_ollamaUrl}/api/generate", content);
            response.EnsureSuccessStatusCode();

            var responseContent = await response.Content.ReadAsStringAsync();
            using var doc = JsonDocument.Parse(responseContent);
            return doc.RootElement.GetProperty("response").GetString() ?? "";
        }

        private VocabularyAIResponse ParseVocabularyResponse(string jsonResponse, string word)
        {
            try
            {
                // Try to extract JSON from the response
                var cleanedResponse = ExtractJsonFromResponse(jsonResponse);
                using var doc = JsonDocument.Parse(cleanedResponse);
                var root = doc.RootElement;

                return new VocabularyAIResponse
                {
                    Word = word,
                    Meaning = root.TryGetProperty("meaning", out var meaning) ? meaning.GetString() ?? "" : "",
                    IPA = root.TryGetProperty("ipa", out var ipa) ? ipa.GetString() ?? "" : "",
                    WordType = root.TryGetProperty("wordType", out var wordType) ? wordType.GetString() ?? "noun" : "noun",
                    Example = root.TryGetProperty("example", out var example) ? example.GetString() ?? "" : "",
                    CEFRLevel = root.TryGetProperty("cefrLevel", out var cefrLevel) ? cefrLevel.GetString() ?? "B1" : "B1"
                };
            }
            catch
            {
                return new VocabularyAIResponse
                {
                    Word = word,
                    Meaning = "",
                    IPA = "",
                    WordType = "noun",
                    Example = "",
                    CEFRLevel = "B1"
                };
            }
        }

        private WritingCheckAIResponse ParseWritingCheckResponse(string jsonResponse)
        {
            try
            {
                var cleanedResponse = ExtractJsonFromResponse(jsonResponse);
                using var doc = JsonDocument.Parse(cleanedResponse);
                var root = doc.RootElement;

                var errors = new List<WritingCheckError>();
                if (root.TryGetProperty("errors", out var errorsArray))
                {
                    foreach (var error in errorsArray.EnumerateArray())
                    {
                        errors.Add(new WritingCheckError
                        {
                            Type = error.TryGetProperty("type", out var type) ? type.GetString() ?? "" : "",
                            Message = error.TryGetProperty("message", out var msg) ? msg.GetString() ?? "" : "",
                            Position = error.TryGetProperty("position", out var pos) ? pos.GetInt32() : 0
                        });
                    }
                }

                var suggestions = new List<WritingCheckSuggestion>();
                if (root.TryGetProperty("suggestions", out var suggestionsArray))
                {
                    foreach (var sugg in suggestionsArray.EnumerateArray())
                    {
                        suggestions.Add(new WritingCheckSuggestion
                        {
                            Current = sugg.TryGetProperty("current", out var current) ? current.GetString() ?? "" : "",
                            Suggested = sugg.TryGetProperty("suggested", out var suggested) ? suggested.GetString() ?? "" : "",
                            Reason = sugg.TryGetProperty("reason", out var reason) ? reason.GetString() ?? "" : ""
                        });
                    }
                }

                var score = root.TryGetProperty("score", out var scoreVal) ? scoreVal.GetInt32() : 5;

                return new WritingCheckAIResponse
                {
                    Score = Math.Min(10, Math.Max(0, score)),
                    Errors = errors,
                    Suggestions = suggestions
                };
            }
            catch
            {
                return new WritingCheckAIResponse
                {
                    Score = 5,
                    Errors = new(),
                    Suggestions = new()
                };
            }
        }

        private string ExtractJsonFromResponse(string response)
        {
            // Find the first { and last } to extract JSON
            int startIndex = response.IndexOf('{');
            int lastIndex = response.LastIndexOf('}');

            if (startIndex >= 0 && lastIndex > startIndex)
            {
                return response.Substring(startIndex, lastIndex - startIndex + 1);
            }

            return "{}";
        }
    }

    public class VocabularyAIResponse
    {
        public string Word { get; set; } = string.Empty;
        public string Meaning { get; set; } = string.Empty;
        public string IPA { get; set; } = string.Empty;
        public string WordType { get; set; } = string.Empty;
        public string Example { get; set; } = string.Empty;
        public string CEFRLevel { get; set; } = string.Empty;
    }

    public class WritingCheckError
    {
        public string Type { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public int Position { get; set; }
    }

    public class WritingCheckSuggestion
    {
        public string Current { get; set; } = string.Empty;
        public string Suggested { get; set; } = string.Empty;
        public string Reason { get; set; } = string.Empty;
    }

    public class WritingCheckAIResponse
    {
        public int Score { get; set; }
        public List<WritingCheckError> Errors { get; set; } = new();
        public List<WritingCheckSuggestion> Suggestions { get; set; } = new();
    }
}
