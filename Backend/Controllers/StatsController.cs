using Backend.DTOs;
using Backend.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;

namespace Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class StatsController : ControllerBase
    {
        private readonly IStatsService _statsService;
        private readonly ILogger<StatsController> _logger;

        public StatsController(IStatsService statsService, ILogger<StatsController> logger)
        {
            _statsService = statsService;
            _logger = logger;
        }

        private int GetUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!int.TryParse(userIdClaim, out var userId))
                throw new UnauthorizedAccessException("User ID not found in token");
            return userId;
        }

        [HttpGet("stats")]
        public async Task<ActionResult<StatsResponse>> GetStats()
        {
            try
            {
                var userId = GetUserId();
                var result = await _statsService.GetStatsAsync(userId);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting stats");
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpGet("dashboard")]
        public async Task<ActionResult<DashboardResponse>> GetDashboard()
        {
            try
            {
                var userId = GetUserId();
                var result = await _statsService.GetDashboardAsync(userId);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting dashboard");
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("update-streak")]
        public async Task<ActionResult> UpdateStreak()
        {
            try
            {
                var userId = GetUserId();
                await _statsService.UpdateStreakAsync(userId);
                return Ok(new { message = "Streak updated" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating streak");
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}
