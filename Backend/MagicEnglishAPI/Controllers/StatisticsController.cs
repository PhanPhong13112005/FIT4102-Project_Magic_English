using Microsoft.AspNetCore.Mvc;
using MagicEnglishAPI.DTOs;
using MagicEnglishAPI.Services;

namespace MagicEnglishAPI.Controllers;

/// <summary>
/// Controller for statistics and dashboard endpoints
/// </summary>
[ApiController]
[Route("api/v1/[controller]")]
[Produces("application/json")]
public class StatisticsController : ControllerBase
{
    private readonly IStatisticsService _statisticsService;
    private readonly ILogger<StatisticsController> _logger;

    public StatisticsController(IStatisticsService statisticsService, ILogger<StatisticsController> logger)
    {
        _statisticsService = statisticsService;
        _logger = logger;
    }

    /// <summary>
    /// Get user dashboard with all statistics
    /// </summary>
    [HttpGet("dashboard")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<DashboardDto>> GetDashboard([FromQuery] int userId, CancellationToken cancellationToken)
    {
        try
        {
            var dashboard = await _statisticsService.GetDashboardAsync(userId, cancellationToken);
            return Ok(dashboard);
        }
        catch (InvalidOperationException ex)
        {
            _logger.LogWarning(ex, "Dashboard retrieval error");
            return NotFound(new { message = ex.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting dashboard");
            return StatusCode(500, new { message = "Internal server error" });
        }
    }

    /// <summary>
    /// Get user's streak information
    /// </summary>
    [HttpGet("streak")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<ActionResult<StreakDto>> GetStreak([FromQuery] int userId, CancellationToken cancellationToken)
    {
        try
        {
            var streak = await _statisticsService.GetStreakAsync(userId, cancellationToken);
            return Ok(streak);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting streak");
            return StatusCode(500, new { message = "Internal server error" });
        }
    }

    /// <summary>
    /// Get activity trend for the last N days (default 30)
    /// </summary>
    [HttpGet("activity-trend")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<ActionResult<List<DailyActivityDto>>> GetActivityTrend([FromQuery] int userId, [FromQuery] int days = 30, CancellationToken cancellationToken = default)
    {
        try
        {
            if (days < 1 || days > 365)
            {
                return BadRequest(new { message = "Days must be between 1 and 365" });
            }

            var trend = await _statisticsService.GetActivityTrendAsync(userId, days, cancellationToken);
            return Ok(trend);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting activity trend");
            return StatusCode(500, new { message = "Internal server error" });
        }
    }
}
