using MagicEnglishAPI.DTOs;
using MagicEnglishAPI.Models;

namespace MagicEnglishAPI.Services;

/// <summary>
/// Interface for vocabulary operations
/// </summary>
public interface IVocabularyService
{
    /// <summary>
    /// Add a new vocabulary entry for a user
    /// </summary>
    Task<VocabularyDto> AddVocabularyAsync(int userId, AddVocabularyDto dto, CancellationToken cancellationToken = default);

    /// <summary>
    /// Get all vocabularies for a user
    /// </summary>
    Task<List<VocabularyDto>> GetUserVocabulariesAsync(int userId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Search vocabularies by word
    /// </summary>
    Task<List<VocabularyDto>> SearchVocabulariesAsync(int userId, string searchTerm, CancellationToken cancellationToken = default);

    /// <summary>
    /// Get vocabulary statistics
    /// </summary>
    Task<VocabularyStatisticsDto> GetVocabularyStatisticsAsync(int userId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Delete a vocabulary entry
    /// </summary>
    Task<bool> DeleteVocabularyAsync(int vocabularyId, CancellationToken cancellationToken = default);
}
