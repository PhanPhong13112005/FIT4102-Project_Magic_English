using Microsoft.AspNetCore.Mvc;
using MagicEnglishAPI.DTOs;
using MagicEnglishAPI.Services;

namespace MagicEnglishAPI.Controllers;

/// <summary>
/// Controller for grammar checking endpoints
/// </summary>
[ApiController]
[Route("api/v1/[controller]")]
[Produces("application/json")]
public class GrammarController : ControllerBase
{
    private readonly IGrammarService _grammarService;
    private readonly IStatisticsService _statisticsService;
    private readonly ILogger<GrammarController> _logger;

    public GrammarController(IGrammarService grammarService, IStatisticsService statisticsService, ILogger<GrammarController> logger)
    {
        _grammarService = grammarService;
        _statisticsService = statisticsService;
        _logger = logger;
    }

    /// <summary>
    /// Check grammar of a text
    /// </summary>
    [HttpPost("check")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<GrammarCheckResponseDto>> CheckGrammar(int userId, [FromBody] GrammarCheckRequestDto dto, CancellationToken cancellationToken)
    {
        try
        {
            if (!ModelState.IsValid || string.IsNullOrWhiteSpace(dto.Text))
            {
                return BadRequest(new { message = "Text is required" });
            }

            var result = await _grammarService.CheckGrammarAsync(userId, dto, cancellationToken);
            
            // Update streak
            await _statisticsService.UpdateStreakAsync(userId, cancellationToken);
            
            return Ok(result);
        }
        catch (InvalidOperationException ex)
        {
            _logger.LogWarning(ex, "Grammar check error");
            return NotFound(new { message = ex.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error checking grammar");
            return StatusCode(500, new { message = "Internal server error" });
        }
    }

    /// <summary>
    /// Get grammar check history for a user
    /// </summary>
    [HttpGet("history")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<ActionResult<List<GrammarCheckResponseDto>>> GetHistory([FromQuery] int userId, [FromQuery] int pageSize = 10, CancellationToken cancellationToken = default)
    {
        try
        {
            var history = await _grammarService.GetGrammarHistoryAsync(userId, pageSize, cancellationToken);
            return Ok(history);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting grammar history");
            return StatusCode(500, new { message = "Internal server error" });
        }
    }

    /// <summary>
    /// Get a specific grammar check result
    /// </summary>
    [HttpGet("{id}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<GrammarCheckResponseDto>> GetGrammarCheck(int id, CancellationToken cancellationToken)
    {
        try
        {
            var check = await _grammarService.GetGrammarCheckAsync(id, cancellationToken);
            if (check == null)
            {
                return NotFound(new { message = "Grammar check not found" });
            }
            return Ok(check);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting grammar check");
            return StatusCode(500, new { message = "Internal server error" });
        }
    }
}
