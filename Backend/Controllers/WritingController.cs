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
    public class WritingController : ControllerBase
    {
        private readonly IWritingService _writingService;
        private readonly ILogger<WritingController> _logger;

        public WritingController(IWritingService writingService, ILogger<WritingController> logger)
        {
            _writingService = writingService;
            _logger = logger;
        }

        private int GetUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!int.TryParse(userIdClaim, out var userId))
                throw new UnauthorizedAccessException("User ID not found in token");
            return userId;
        }

        [HttpPost("check")]
        public async Task<ActionResult<WritingCheckResponse>> CheckWriting([FromBody] WritingCheckRequest request)
        {
            try
            {
                var userId = GetUserId();
                var result = await _writingService.CheckWritingAsync(userId, request);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking writing");
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpGet("submissions")]
        public async Task<ActionResult<List<WritingCheckResponse>>> GetAllSubmissions()
        {
            try
            {
                var userId = GetUserId();
                var result = await _writingService.GetUserSubmissionsAsync(userId);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting submissions");
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}
