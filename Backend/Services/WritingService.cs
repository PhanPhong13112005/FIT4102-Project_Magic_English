using Backend.DTOs;

namespace Backend.Services
{
    // 1. Định nghĩa Interface ngay tại đây
    public interface IWritingService
    {
        Task<WritingCheckResponse> CheckWritingAsync(int userId, WritingCheckRequest request);
        Task<List<WritingCheckResponse>> GetUserSubmissionsAsync(int userId);
    }

    // 2. Triển khai Class dịch vụ
    public class WritingService : IWritingService
    {
        private readonly IGeminiService _geminiService;

        // Tiêm GeminiService vào để dùng chung
        public WritingService(IGeminiService geminiService)
        {
            _geminiService = geminiService;
        }

        public async Task<WritingCheckResponse> CheckWritingAsync(int userId, WritingCheckRequest request)
        {
            // Prompt đã được tối ưu cho giáo viên IELTS
            string prompt = $@"
                Bạn là giáo viên IELTS. Phân tích đoạn văn sau và trả về JSON chuẩn:
                {{
                  ""score"": <int 0-10>,
                  ""errors"": [
                    {{ ""position"": <int>, ""errorType"": ""<grammar/spelling/style>"", ""message"": ""<tiếng Việt>"" }}
                  ],
                  ""suggestions"": [
                    {{ ""current"": ""<string>"", ""suggested"": ""<string>"", ""reason"": ""<tiếng Việt>"" }}
                  ]
                }}
                Text: ""{request.Content}""";

            // Gọi trạm trung chuyển GeminiService để lấy kết quả
            return await _geminiService.GenerateContentAsync<WritingCheckResponse>(prompt);
        }

        public Task<List<WritingCheckResponse>> GetUserSubmissionsAsync(int userId)
        {
            return Task.FromResult(new List<WritingCheckResponse>());
        }
    }
}