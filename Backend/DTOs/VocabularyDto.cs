namespace Backend.DTOs
{
    public class VocabularyDto
    {
        public int Id { get; set; }
        public string Word { get; set; } = string.Empty;
        public string Meaning { get; set; } = string.Empty;
        public string IPA { get; set; } = string.Empty;
        public string WordType { get; set; } = string.Empty;
        public string Example { get; set; } = string.Empty;
        public string CEFRLevel { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
    }

    public class AddVocabularyRequest
    {
        public string Word { get; set; } = string.Empty;
    }

    public class VocabularyListResponse
    {
        public List<VocabularyDto> Items { get; set; } = new();
        public int TotalCount { get; set; }
    }
}
