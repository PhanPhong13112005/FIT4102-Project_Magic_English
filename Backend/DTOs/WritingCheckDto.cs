namespace Backend.DTOs
{
    public class WritingCheckRequest
    {
        public string Content { get; set; } = string.Empty;
    }

    public class WritingError
    {
        public int Position { get; set; }
        public string ErrorType { get; set; } = string.Empty; // grammar, spelling, style
        public string Message { get; set; } = string.Empty;
    }

    public class WritingSuggestion
    {
        public string Current { get; set; } = string.Empty;
        public string Suggested { get; set; } = string.Empty;
        public string Reason { get; set; } = string.Empty;
    }

    public class WritingCheckResponse
    {
        public int Score { get; set; } // 0-10
        public List<WritingError> Errors { get; set; } = new();
        public List<WritingSuggestion> Suggestions { get; set; } = new();
    }
}
