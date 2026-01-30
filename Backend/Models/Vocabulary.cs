namespace Backend.Models
{
    public class Vocabulary
    {
        public int Id { get; set; }
        public string Word { get; set; } = string.Empty;
        public string Meaning { get; set; } = string.Empty;
        public string IPA { get; set; } = string.Empty;
        public string WordType { get; set; } = string.Empty; // noun, verb, adj, etc
        public string Example { get; set; } = string.Empty;
        public string CEFRLevel { get; set; } = string.Empty; // A1, A2, B1, B2, C1, C2
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        // Foreign key
        public int UserId { get; set; }
        public virtual User? User { get; set; }
    }
}
