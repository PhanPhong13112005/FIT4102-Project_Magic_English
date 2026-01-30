using Backend.Data;
using Backend.DTOs;
using Backend.Models;
using Microsoft.EntityFrameworkCore;

namespace Backend.Services
{
    public interface IWritingService
    {
        Task<WritingCheckResponse> CheckWritingAsync(int userId, WritingCheckRequest request);
        Task<List<WritingCheckResponse>> GetUserSubmissionsAsync(int userId);
    }

    public class WritingService : IWritingService
    {
        private readonly AppDbContext _dbContext;
        private readonly IOllamaService _ollamaService;
        private readonly IStatsService _statsService;

        public WritingService(AppDbContext dbContext, IOllamaService ollamaService, IStatsService statsService)
        {
            _dbContext = dbContext;
            _ollamaService = ollamaService;
            _statsService = statsService;
        }

        public async Task<WritingCheckResponse> CheckWritingAsync(int userId, WritingCheckRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Content))
                throw new ArgumentException("Content cannot be empty");

            // Get feedback from AI
            var aiResponse = await _ollamaService.CheckWritingAsync(request.Content);

            // Save submission to database
            var submission = new WritingSubmission
            {
                UserId = userId,
                Content = request.Content,
                Score = aiResponse.Score,
                Errors = System.Text.Json.JsonSerializer.Serialize(aiResponse.Errors),
                Suggestions = System.Text.Json.JsonSerializer.Serialize(aiResponse.Suggestions),
                CreatedAt = DateTime.UtcNow
            };

            _dbContext.WritingSubmissions.Add(submission);
            await _dbContext.SaveChangesAsync();

            // Update user stats
            await _statsService.RecordWritingSubmissionAsync(userId);

            return MapToResponse(aiResponse);
        }

        public async Task<List<WritingCheckResponse>> GetUserSubmissionsAsync(int userId)
        {
            var submissions = await _dbContext.WritingSubmissions
                .Where(w => w.UserId == userId)
                .OrderByDescending(w => w.CreatedAt)
                .ToListAsync();

            var results = new List<WritingCheckResponse>();
            foreach (var submission in submissions)
            {
                var errors = System.Text.Json.JsonSerializer.Deserialize<List<WritingError>>(submission.Errors) ?? new();
                var suggestions = System.Text.Json.JsonSerializer.Deserialize<List<WritingSuggestion>>(submission.Suggestions) ?? new();

                results.Add(new WritingCheckResponse
                {
                    Score = submission.Score,
                    Errors = errors,
                    Suggestions = suggestions
                });
            }

            return results;
        }

        private WritingCheckResponse MapToResponse(Services.WritingCheckAIResponse aiResponse)
        {
            return new WritingCheckResponse
            {
                Score = aiResponse.Score,
                Errors = aiResponse.Errors.Select(e => new WritingError
                {
                    Position = e.Position,
                    ErrorType = e.Type,
                    Message = e.Message
                }).ToList(),
                Suggestions = aiResponse.Suggestions.Select(s => new WritingSuggestion
                {
                    Current = s.Current,
                    Suggested = s.Suggested,
                    Reason = s.Reason
                }).ToList()
            };
        }
    }
}
