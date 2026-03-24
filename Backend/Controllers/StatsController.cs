using Backend.DTOs;
using Backend.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;

namespace Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    //[Authorize]
    public class StatsController : ControllerBase
    {
        private readonly IStatsService _statsService;
        private readonly ILogger<StatsController> _logger;

        public StatsController(IStatsService statsService, ILogger<StatsController> logger)
        {
            _statsService = statsService;
            _logger = logger;
        }

        // private int GetUserId()
        // {
        //     var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        //     if (!int.TryParse(userIdClaim, out var userId))
        //         throw new UnauthorizedAccessException("Không tìm thấy ID người dùng trong mã thông báo");
        //     return 1; // Tạm thời trả về ID mặc định để test trên Swagger
        //     //return userId; // Code thực tế khi chạy App Flutter
        // }
        private int GetUserId()
            {
                // BƯỚC 1: Trả về 1 ngay lập tức để bỏ qua mọi kiểm tra bên dưới
                return 1; 

                /* BƯỚC 2: Tạm thời vô hiệu hóa (Comment) toàn bộ đoạn này để không bị throw lỗi
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (!int.TryParse(userIdClaim, out var userId))
                    throw new UnauthorizedAccessException("Không tìm thấy ID người dùng trong mã thông báo");
                
                return userId; 
                */
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
                _logger.LogError(ex, "Lỗi khi lấy thống kê");
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
                _logger.LogError(ex, "Lỗi khi lấy bảng điều khiển");
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
                return Ok(new { message = "Đã cập nhật chuỗi" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi cập nhật chuỗi");
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}
