using MagicEnglishAPI.DTOs;

namespace MagicEnglishAPI.Services;

/// <summary>
/// Interface for grammar checking operations
/// </summary>
public interface IGrammarService
{
    /// <summary>
    /// Check grammar of a text
    /// </summary>
    Task<GrammarCheckResponseDto> CheckGrammarAsync(int userId, GrammarCheckRequestDto dto, CancellationToken cancellationToken = default);

    /// <summary>
    /// Get grammar check history for a user
    /// </summary>
    Task<List<GrammarCheckResponseDto>> GetGrammarHistoryAsync(int userId, int pageSize = 10, CancellationToken cancellationToken = default);

    /// <summary>
    /// Get a specific grammar check result
    /// </summary>
    Task<GrammarCheckResponseDto?> GetGrammarCheckAsync(int checkId, CancellationToken cancellationToken = default);
}
