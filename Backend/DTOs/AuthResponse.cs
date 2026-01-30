namespace Backend.DTOs
{
    public class AuthResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; } = string.Empty;
        public AuthResponseData? Data { get; set; }
    }

    public class AuthResponseData
    {
        public int UserId { get; set; }
        public required string Email { get; set; }
        public required string Username { get; set; }
        public required string FullName { get; set; }
        public required string Token { get; set; }
        public DateTime TokenExpiration { get; set; }
    }
}
