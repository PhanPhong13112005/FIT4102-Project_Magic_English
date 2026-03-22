using Microsoft.AspNetCore.Mvc;
using MagicEnglishAPI.DTOs;
using MagicEnglishAPI.Services;

namespace MagicEnglishAPI.Controllers;

/// <summary>
/// Controller for vocabulary management endpoints
/// </summary>
[ApiController]
[Route("api/v1/[controller]")]
[Produces("application/json")]
public class VocabularyController : ControllerBase
{
    private readonly IVocabularyService _vocabularyService;
    private readonly IStatisticsService _statisticsService;
    private readonly ILogger<VocabularyController> _logger;

    public VocabularyController(IVocabularyService vocabularyService, IStatisticsService statisticsService, ILogger<VocabularyController> logger)
    {
        _vocabularyService = vocabularyService;
        _statisticsService = statisticsService;
        _logger = logger;
    }

    /// <summary>
    /// Add a new vocabulary word
    /// </summary>
    [HttpPost("add")]
    [ProducesResponseType(StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<VocabularyDto>> AddVocabulary(int userId, [FromBody] AddVocabularyDto dto, CancellationToken cancellationToken)
    {
        try
        {
            if (!ModelState.IsValid || string.IsNullOrWhiteSpace(dto.Word))
            {
                return BadRequest(new { message = "Word is required" });
            }

            var vocabulary = await _vocabularyService.AddVocabularyAsync(userId, dto, cancellationToken);
            
            // Update streak
            await _statisticsService.UpdateStreakAsync(userId, cancellationToken);
            
            return CreatedAtAction(nameof(GetVocabulary), new { id = vocabulary.Id }, vocabulary);
        }
        catch (InvalidOperationException ex)
        {
            _logger.LogWarning(ex, "Vocabulary addition error");
            return NotFound(new { message = ex.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error adding vocabulary");
            return StatusCode(500, new { message = "Internal server error" });
        }
    }

    /// <summary>
    /// Get all vocabularies for a user
    /// </summary>
    [HttpGet("list")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<List<VocabularyDto>>> GetVocabularyList(int userId, CancellationToken cancellationToken)
    {
        try
        {
            var vocabularies = await _vocabularyService.GetUserVocabulariesAsync(userId, cancellationToken);
            return Ok(vocabularies);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting vocabulary list");
            return StatusCode(500, new { message = "Internal server error" });
        }
    }

    /// <summary>
    /// Search vocabularies by word, meaning, or example
    /// </summary>
    [HttpGet("search")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<ActionResult<List<VocabularyDto>>> SearchVocabulary(int userId, [FromQuery] string query, CancellationToken cancellationToken)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(query))
            {
                return BadRequest(new { message = "Search query is required" });
            }

            var vocabularies = await _vocabularyService.SearchVocabulariesAsync(userId, query, cancellationToken);
            return Ok(vocabularies);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error searching vocabularies");
            return StatusCode(500, new { message = "Internal server error" });
        }
    }

    /// <summary>
    /// Get a specific vocabulary by ID
    /// </summary>
    [HttpGet("{id}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<VocabularyDto>> GetVocabulary(int id, CancellationToken cancellationToken)
    {
        try
        {
            // Note: In a real app, you'd want to fetch this properly
            // For now, this is a placeholder
            return NotFound(new { message = "Vocabulary not found" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting vocabulary");
            return StatusCode(500, new { message = "Internal server error" });
        }
    }

    /// <summary>
    /// Get vocabulary statistics for a user
    /// </summary>
    [HttpGet("statistics")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<ActionResult<VocabularyStatisticsDto>> GetStatistics(int userId, CancellationToken cancellationToken)
    {
        try
        {
            var statistics = await _vocabularyService.GetVocabularyStatisticsAsync(userId, cancellationToken);
            return Ok(statistics);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting vocabulary statistics");
            return StatusCode(500, new { message = "Internal server error" });
        }
    }

    /// <summary>
    /// Delete a vocabulary entry
    /// </summary>
    [HttpDelete("{id}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> DeleteVocabulary(int id, CancellationToken cancellationToken)
    {
        try
        {
            var success = await _vocabularyService.DeleteVocabularyAsync(id, cancellationToken);
            if (!success)
            {
                return NotFound(new { message = "Vocabulary not found" });
            }
            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting vocabulary");
            return StatusCode(500, new { message = "Internal server error" });
        }
    }
}
