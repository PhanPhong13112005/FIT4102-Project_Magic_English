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
        private readonly IGeminiService _geminiService;
        private readonly IStatsService _statsService;

        public VocabularyService(AppDbContext dbContext, IGeminiService geminiService, IStatsService statsService)
        {
            _dbContext = dbContext;
            _geminiService = geminiService;
            _statsService = statsService;
        }

        public class VocabularyAiResponse
        {
            public string Word { get; set; } = string.Empty;
            public string Meaning { get; set; } = string.Empty;
            public string IPA { get; set; } = string.Empty;
            public string WordType { get; set; } = string.Empty;
            public string Example { get; set; } = string.Empty;
            public string CEFRLevel { get; set; } = string.Empty;
        }

        public async Task<VocabularyDto> AddVocabularyAsync(int userId, AddVocabularyRequest request)
        {
            try 
            {
                if (string.IsNullOrWhiteSpace(request.Word))
                    throw new ArgumentException("Từ vựng không được để trống.");

                var existing = await _dbContext.Vocabularies
                    .FirstOrDefaultAsync(v => v.UserId == userId && v.Word.ToLower() == request.Word.ToLower());

                if (existing != null) return MapToDto(existing);

                string prompt = $@"
                    Phân tích từ vựng: ""{request.Word}"". Trả về duy nhất JSON:
                    {{
                      ""word"": ""{request.Word}"", ""meaning"": ""<Nghĩa VN>"", ""ipa"": ""<IPA>"",
                      ""wordType"": ""<Loại từ>"", ""example"": ""<Ví dụ>"", ""cefrLevel"": ""<A1-C2>""
                    }}";

                var aiResponse = await _geminiService.GenerateContentAsync<VocabularyAiResponse>(prompt);

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
                
                // Lưu vào Database - Chỗ này thường gây lỗi nếu thiếu User 1
                await _dbContext.SaveChangesAsync();

                await _statsService.RecordVocabularyAddedAsync(userId);

                return MapToDto(vocabulary);
            }
            catch (DbUpdateException ex)
            {
                // Trả về lỗi chi tiết nhất từ SQL cho Swagger
                var innerError = ex.InnerException?.Message ?? ex.Message;
                throw new Exception($"Lỗi Database: {innerError}");
            }
            catch (Exception ex)
            {
                throw new Exception($"Lỗi Writing Service: {ex.Message}");
            }
        }

        public async Task<VocabularyListResponse> GetUserVocabulariesAsync(int userId, int page = 1, int pageSize = 20)
        {
            var query = _dbContext.Vocabularies.Where(v => v.UserId == userId);
            var totalCount = await query.CountAsync();
            var items = await query.OrderByDescending(v => v.CreatedAt).Skip((page - 1) * pageSize).Take(pageSize).ToListAsync();
            return new VocabularyListResponse { Items = items.Select(MapToDto).ToList(), TotalCount = totalCount };
        }

        public async Task<VocabularyDto?> GetVocabularyByIdAsync(int userId, int vocabId)
        {
            var vocab = await _dbContext.Vocabularies.FirstOrDefaultAsync(v => v.Id == vocabId && v.UserId == userId);
            return vocab != null ? MapToDto(vocab) : null;
        }

        public async Task<List<VocabularyDto>> SearchVocabularyAsync(int userId, string searchTerm)
        {
            var results = await _dbContext.Vocabularies.Where(v => v.UserId == userId && (v.Word.Contains(searchTerm) || v.Meaning.Contains(searchTerm))).OrderBy(v => v.Word).ToListAsync();
            return results.Select(MapToDto).ToList();
        }

        private VocabularyDto MapToDto(Vocabulary vocab)
        {
            return new VocabularyDto { Id = vocab.Id, Word = vocab.Word, Meaning = vocab.Meaning, IPA = vocab.IPA, WordType = vocab.WordType, Example = vocab.Example, CEFRLevel = vocab.CEFRLevel, CreatedAt = vocab.CreatedAt };
        }
    }
}