using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using MagicEnglishAPI.Data;
using MagicEnglishAPI.DTOs;
using MagicEnglishAPI.Models;

namespace MagicEnglishAPI.Services;

/// <summary>
/// Service for grammar checking operations
/// </summary>
public class GrammarService : IGrammarService
{
    private readonly MagicEnglishDbContext _context;
    private readonly IOllamaService _ollamaService;
    private readonly ILogger<GrammarService> _logger;

    public GrammarService(MagicEnglishDbContext context, IOllamaService ollamaService, ILogger<GrammarService> logger)
    {
        _context = context;
        _ollamaService = ollamaService;
        _logger = logger;
    }

    public async Task<GrammarCheckResponseDto> CheckGrammarAsync(int userId, GrammarCheckRequestDto dto, CancellationToken cancellationToken = default)
    {
        try
        {
            _logger.LogInformation("Checking grammar for user {UserId}, text length: {TextLength}", userId, dto.Text.Length);

            // Check if user exists
            var user = await _context.Users.FindAsync(new object[] { userId }, cancellationToken: cancellationToken);
            if (user == null)
            {
                throw new InvalidOperationException($"User with ID {userId} not found");
            }

            // Call Ollama API for grammar checking
            var grammarResult = await _ollamaService.CheckGrammarAsync(dto.Text, cancellationToken);

            // Serialize errors and suggestions to JSON
            var errorsJson = JsonSerializer.Serialize(grammarResult?.Errors ?? new List<GrammarErrorDetail>());
            var suggestionsJson = JsonSerializer.Serialize(grammarResult?.Suggestions ?? new List<string>());

            var grammarCheck = new GrammarCheck
            {
                UserId = userId,
                OriginalText = dto.Text,
                Score = grammarResult?.Score ?? 0,
                Errors = errorsJson,
                Suggestions = suggestionsJson,
                CreatedAt = DateTime.UtcNow
            };

            _context.GrammarChecks.Add(grammarCheck);

            // Record study activity
            var activity = new StudyActivity
            {
                UserId = userId,
                ActivityType = ActivityType.Grammar,
                CreatedAt = DateTime.UtcNow
            };
            _context.StudyActivities.Add(activity);

            await _context.SaveChangesAsync(cancellationToken);

            _logger.LogInformation("Successfully checked grammar for user {UserId}", userId);

            return MapToDto(grammarCheck);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error checking grammar for user {UserId}", userId);
            throw;
        }
    }

    public async Task<List<GrammarCheckResponseDto>> GetGrammarHistoryAsync(int userId, int pageSize = 10, CancellationToken cancellationToken = default)
    {
        try
        {
            var grammarChecks = await _context.GrammarChecks
                .Where(g => g.UserId == userId)
                .OrderByDescending(g => g.CreatedAt)
                .Take(pageSize)
                .ToListAsync(cancellationToken);

            return grammarChecks.Select(MapToDto).ToList();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting grammar history for user {UserId}", userId);
            throw;
        }
    }

    public async Task<GrammarCheckResponseDto?> GetGrammarCheckAsync(int checkId, CancellationToken cancellationToken = default)
    {
        try
        {
            var grammarCheck = await _context.GrammarChecks.FindAsync(new object[] { checkId }, cancellationToken: cancellationToken);
            return grammarCheck != null ? MapToDto(grammarCheck) : null;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting grammar check {CheckId}", checkId);
            throw;
        }
    }

    private GrammarCheckResponseDto MapToDto(GrammarCheck grammarCheck)
    {
        var errors = new List<GrammarErrorDto>();
        var suggestions = new List<string>();

        try
        {
            if (!string.IsNullOrEmpty(grammarCheck.Errors))
            {
                var errorsList = JsonSerializer.Deserialize<List<GrammarErrorDetail>>(grammarCheck.Errors);
                if (errorsList != null)
                {
                    errors = errorsList.Select(e => new GrammarErrorDto
                    {
                        Type = e.Type,
                        Description = e.Description,
                        Position = e.Position,
                        SuggestedFix = e.SuggestedFix
                    }).ToList();
                }
            }

            if (!string.IsNullOrEmpty(grammarCheck.Suggestions))
            {
                var suggestionsList = JsonSerializer.Deserialize<List<string>>(grammarCheck.Suggestions);
                if (suggestionsList != null)
                {
                    suggestions = suggestionsList;
                }
            }
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Error deserializing grammar check data for check {CheckId}", grammarCheck.Id);
        }

        return new GrammarCheckResponseDto
        {
            Id = grammarCheck.Id,
            OriginalText = grammarCheck.OriginalText,
            Score = grammarCheck.Score,
            Errors = errors,
            Suggestions = suggestions,
            CreatedAt = grammarCheck.CreatedAt
        };
    }
}
