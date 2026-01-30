namespace Backend.Models
{
    public class User
    {
        public int Id { get; set; }
        public string Email { get; set; } = string.Empty;
        public string Username { get; set; } = string.Empty;
        public string PasswordHash { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
        public bool IsActive { get; set; } = true;

        // Navigation properties
        public virtual ICollection<Vocabulary> Vocabularies { get; set; } = new List<Vocabulary>();
        public virtual ICollection<WritingSubmission> WritingSubmissions { get; set; } = new List<WritingSubmission>();
        public virtual UserStats? UserStats { get; set; }
    }
}
