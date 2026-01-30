using Backend.Data;
using Backend.DTOs;
using Backend.Models;
using Microsoft.EntityFrameworkCore;

namespace Backend.Services
{
    public interface IVocabularyService
    {
        Task<VocabularyDto> AddVocabularyAsync(int userId, AddVocabularyRequest request);
        Task<VocabularyListResponse> GetUserVocabulariesAsync(int userId, int page = 1, int pageSize = 20);
        Task<VocabularyDto?> GetVocabularyByIdAsync(int userId, int vocabId);
        Task<List<VocabularyDto>> SearchVocabularyAsync(int userId, string searchTerm);
    }

    public class VocabularyService : IVocabularyService
    {
        private readonly AppDbContext _dbContext;
        private readonly IOllamaService _ollamaService;
        private readonly IStatsService _statsService;

        public VocabularyService(AppDbContext dbContext, IOllamaService ollamaService, IStatsService statsService)
        {
            _dbContext = dbContext;
            _ollamaService = ollamaService;
            _statsService = statsService;
        }

        public async Task<VocabularyDto> AddVocabularyAsync(int userId, AddVocabularyRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Word))
                throw new ArgumentException("Word cannot be empty");

            // Check if word already exists for this user
            var existing = await _dbContext.Vocabularies
                .FirstOrDefaultAsync(v => v.UserId == userId && v.Word.ToLower() == request.Word.ToLower());

            if (existing != null)
                return MapToDto(existing);

            // Get vocabulary data from AI
            var aiResponse = await _ollamaService.ExtractVocabularyAsync(request.Word);

            // Create new vocabulary entry
            var vocabulary = new Vocabulary
            {
                UserId = userId,
                Word = aiResponse.Word,
                Meaning = aiResponse.Meaning,
                IPA = aiResponse.IPA,
                WordType = aiResponse.WordType,
                Example = aiResponse.Example,
                CEFRLevel = aiResponse.CEFRLevel,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            _dbContext.Vocabularies.Add(vocabulary);
            await _dbContext.SaveChangesAsync();

            // Update user stats
            await _statsService.RecordVocabularyAddedAsync(userId);

            return MapToDto(vocabulary);
        }

        public async Task<VocabularyListResponse> GetUserVocabulariesAsync(int userId, int page = 1, int pageSize = 20)
        {
            var query = _dbContext.Vocabularies.Where(v => v.UserId == userId);
            var totalCount = await query.CountAsync();

            var items = await query
                .OrderByDescending(v => v.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return new VocabularyListResponse
            {
                Items = items.Select(MapToDto).ToList(),
                TotalCount = totalCount
            };
        }

        public async Task<VocabularyDto?> GetVocabularyByIdAsync(int userId, int vocabId)
        {
            var vocab = await _dbContext.Vocabularies
                .FirstOrDefaultAsync(v => v.Id == vocabId && v.UserId == userId);
            return vocab != null ? MapToDto(vocab) : null;
        }

        public async Task<List<VocabularyDto>> SearchVocabularyAsync(int userId, string searchTerm)
        {
            var results = await _dbContext.Vocabularies
                .Where(v => v.UserId == userId && (v.Word.Contains(searchTerm) || v.Meaning.Contains(searchTerm)))
                .OrderBy(v => v.Word)
                .ToListAsync();

            return results.Select(MapToDto).ToList();
        }

        private VocabularyDto MapToDto(Vocabulary vocab)
        {
            return new VocabularyDto
            {
                Id = vocab.Id,
                Word = vocab.Word,
                Meaning = vocab.Meaning,
                IPA = vocab.IPA,
                WordType = vocab.WordType,
                Example = vocab.Example,
                CEFRLevel = vocab.CEFRLevel,
                CreatedAt = vocab.CreatedAt
            };
        }
    }
}
