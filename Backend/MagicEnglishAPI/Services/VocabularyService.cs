using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using MagicEnglishAPI.Data;
using MagicEnglishAPI.DTOs;
using MagicEnglishAPI.Models;

namespace MagicEnglishAPI.Services;

/// <summary>
/// Service for vocabulary operations
/// </summary>
public class VocabularyService : IVocabularyService
{
    private readonly MagicEnglishDbContext _context;
    private readonly IOllamaService _ollamaService;
    private readonly ILogger<VocabularyService> _logger;

    public VocabularyService(MagicEnglishDbContext context, IOllamaService ollamaService, ILogger<VocabularyService> logger)
    {
        _context = context;
        _ollamaService = ollamaService;
        _logger = logger;
    }

    public async Task<VocabularyDto> AddVocabularyAsync(int userId, AddVocabularyDto dto, CancellationToken cancellationToken = default)
    {
        try
        {
            _logger.LogInformation("Adding vocabulary for user {UserId}: {Word}", userId, dto.Word);

            // Check if user exists
            var user = await _context.Users.FindAsync(new object[] { userId }, cancellationToken: cancellationToken);
            if (user == null)
            {
                throw new InvalidOperationException($"User with ID {userId} not found");
            }

            // Check if vocabulary already exists
            var existingVocab = await _context.Vocabularies
                .FirstOrDefaultAsync(v => v.UserId == userId && v.Word.ToLower() == dto.Word.ToLower(), cancellationToken);
            
            if (existingVocab != null)
            {
                _logger.LogWarning("Vocabulary already exists for user {UserId}: {Word}", userId, dto.Word);
                return MapToDto(existingVocab);
            }

            // Enrich vocabulary using Ollama API
            var enrichedData = await _ollamaService.EnrichVocabularyAsync(dto.Word, cancellationToken);

            var vocabulary = new Vocabulary
            {
                UserId = userId,
                Word = dto.Word,
                IPA = enrichedData?.IPA ?? "",
                Meaning = enrichedData?.Meaning ?? "",
                PartOfSpeech = enrichedData?.PartOfSpeech ?? "",
                Example = enrichedData?.Example ?? "",
                CEFRLevel = enrichedData?.CEFRLevel ?? "A1",
                CreatedAt = DateTime.UtcNow
            };

            _context.Vocabularies.Add(vocabulary);

            // Record study activity
            var activity = new StudyActivity
            {
                UserId = userId,
                ActivityType = ActivityType.Vocabulary,
                CreatedAt = DateTime.UtcNow
            };
            _context.StudyActivities.Add(activity);

            await _context.SaveChangesAsync(cancellationToken);

            _logger.LogInformation("Successfully added vocabulary for user {UserId}: {Word}", userId, dto.Word);

            return MapToDto(vocabulary);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error adding vocabulary for user {UserId}", userId);
            throw;
        }
    }

    public async Task<List<VocabularyDto>> GetUserVocabulariesAsync(int userId, CancellationToken cancellationToken = default)
    {
        try
        {
            var vocabularies = await _context.Vocabularies
                .Where(v => v.UserId == userId)
                .OrderByDescending(v => v.CreatedAt)
                .ToListAsync(cancellationToken);

            return vocabularies.Select(MapToDto).ToList();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting vocabularies for user {UserId}", userId);
            throw;
        }
    }

    public async Task<List<VocabularyDto>> SearchVocabulariesAsync(int userId, string searchTerm, CancellationToken cancellationToken = default)
    {
        try
        {
            var vocabularies = await _context.Vocabularies
                .Where(v => v.UserId == userId && (
                    v.Word.Contains(searchTerm) ||
                    v.Meaning.Contains(searchTerm) ||
                    v.Example.Contains(searchTerm)))
                .OrderByDescending(v => v.CreatedAt)
                .ToListAsync(cancellationToken);

            return vocabularies.Select(MapToDto).ToList();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error searching vocabularies for user {UserId}", userId);
            throw;
        }
    }

    public async Task<VocabularyStatisticsDto> GetVocabularyStatisticsAsync(int userId, CancellationToken cancellationToken = default)
    {
        try
        {
            var vocabularies = await _context.Vocabularies
                .Where(v => v.UserId == userId)
                .ToListAsync(cancellationToken);

            var stats = new VocabularyStatisticsDto
            {
                TotalWords = vocabularies.Count,
                PartOfSpeechDistribution = vocabularies
                    .GroupBy(v => v.PartOfSpeech)
                    .ToDictionary(g => g.Key, g => g.Count()),
                CEFRLevelDistribution = vocabularies
                    .GroupBy(v => v.CEFRLevel)
                    .ToDictionary(g => g.Key, g => g.Count())
            };

            return stats;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting vocabulary statistics for user {UserId}", userId);
            throw;
        }
    }

    public async Task<bool> DeleteVocabularyAsync(int vocabularyId, CancellationToken cancellationToken = default)
    {
        try
        {
            var vocabulary = await _context.Vocabularies.FindAsync(new object[] { vocabularyId }, cancellationToken: cancellationToken);
            if (vocabulary == null)
            {
                return false;
            }

            _context.Vocabularies.Remove(vocabulary);
            await _context.SaveChangesAsync(cancellationToken);

            _logger.LogInformation("Successfully deleted vocabulary {VocabularyId}", vocabularyId);
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting vocabulary {VocabularyId}", vocabularyId);
            throw;
        }
    }

    private VocabularyDto MapToDto(Vocabulary vocabulary)
    {
        return new VocabularyDto
        {
            Id = vocabulary.Id,
            Word = vocabulary.Word,
            IPA = vocabulary.IPA,
            Meaning = vocabulary.Meaning,
            PartOfSpeech = vocabulary.PartOfSpeech,
            Example = vocabulary.Example,
            CEFRLevel = vocabulary.CEFRLevel,
            CreatedAt = vocabulary.CreatedAt,
            LastReviewedAt = vocabulary.LastReviewedAt,
            ReviewCount = vocabulary.ReviewCount
        };
    }
}
