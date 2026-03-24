using System.Text.Json;
using System.Net.Http.Json;
using Microsoft.Extensions.Configuration;

namespace Backend.Services
{
    // 1. Định nghĩa Interface ngay tại đây để tiện quản lý
    public interface IGeminiService
    {
        Task<T> GenerateContentAsync<T>(string prompt);
    }

    // 2. Triển khai Class dịch vụ
    public class GeminiService : IGeminiService
    {
        private readonly HttpClient _httpClient;
        private readonly IConfiguration _configuration;

        public GeminiService(HttpClient httpClient, IConfiguration configuration)
        {
            _httpClient = httpClient;
            _configuration = configuration;
        }

        public async Task<T> GenerateContentAsync<T>(string prompt)
        {
            // Lấy API Key từ file appsettings.json của nhóm bạn
            string apiKey = _configuration["GeminiApiKey"] 
                ?? throw new Exception("Lỗi: Chưa cấu hình GeminiApiKey.");

            // Sử dụng đúng Model ID 'preview' và v1beta từ tài liệu bạn tìm thấy
            // Đây là URL "vàng" giúp chạy ngon lành trên năm 2026
            string url = $"https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent?key={apiKey}";

            var payload = new
            {
                contents = new[] 
                { 
                    new { parts = new[] { new { text = prompt } } } 
                }
            };

            // Gửi yêu cầu và đọc phản hồi
            var response = await _httpClient.PostAsJsonAsync(url, payload);
            var responseBody = await response.Content.ReadAsStringAsync();

            if (!response.IsSuccessStatusCode)
            {
                throw new Exception($"Gemini API Error: {responseBody}");
            }

            // Bóc tách dữ liệu từ cấu hình JSON phức tạp của Google
            using var jsonDocument = JsonDocument.Parse(responseBody);
            var rawText = jsonDocument.RootElement
                .GetProperty("candidates")[0]
                .GetProperty("content")
                .GetProperty("parts")[0]
                .GetProperty("text")
                .GetString() ?? string.Empty;

            // Xử lý làm sạch chuỗi (loại bỏ dấu bao Markdown của AI)
            var cleanJson = rawText.Replace("```json", "").Replace("```", "").Trim();

            // Tự động chuyển đổi sang kiểu dữ liệu mong muốn (Generic T)
            var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
            return JsonSerializer.Deserialize<T>(cleanJson, options) 
                   ?? throw new Exception("Lỗi giải mã JSON từ AI.");
        }
    }
}