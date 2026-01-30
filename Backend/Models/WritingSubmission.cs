namespace Backend.Models
{
    public class WritingSubmission
    {
        public int Id { get; set; }
        public string Content { get; set; } = string.Empty;
        public int Score { get; set; } // 0-10 scale
        public string Errors { get; set; } = string.Empty; // JSON formatted errors
        public string Suggestions { get; set; } = string.Empty; // JSON formatted suggestions
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Foreign key
        public int UserId { get; set; }
        public virtual User? User { get; set; }
    }
}
