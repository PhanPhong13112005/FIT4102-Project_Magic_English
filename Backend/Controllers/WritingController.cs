using Backend.DTOs;
using Backend.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;

namespace Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    // [Authorize] // Mở ra khi bạn đã tích hợp xong JWT Token cho App Magic English
    public class WritingController : ControllerBase
    {
        private readonly IWritingService _writingService;

        public WritingController(IWritingService writingService)
        {
            _writingService = writingService;
        }

        /// <summary>
        /// API kiểm tra và chấm điểm đoạn văn tiếng Anh bằng AI
        /// </summary>
        [HttpPost("check")]
        public async Task<IActionResult> CheckWriting([FromBody] WritingCheckRequest request)
        {
            try
            {
                // 1. Kiểm tra đầu vào
                if (request == null || string.IsNullOrWhiteSpace(request.Content))
                {
                    return BadRequest(new { message = "Nội dung đoạn văn không được để trống." });
                }

                // 2. Lấy UserId từ Token (Giả lập là 1 nếu đang tắt Authorize để test)
                int userId = 1;
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (!string.IsNullOrEmpty(userIdClaim))
                {
                    userId = int.Parse(userIdClaim);
                }

                // 3. Gọi Service xử lý AI (Gemini 3 Flash đã cấu hình ngon lành)
                var result = await _writingService.CheckWritingAsync(userId, request);

                // 4. Trả kết quả về cho App Flutter
                return Ok(result);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                // Log lỗi server tại đây nếu cần
                return StatusCode(500, new { message = "Có lỗi xảy ra khi xử lý bài viết: " + ex.Message });
            }
        }

        /// <summary>
        /// Lấy lịch sử các bài đã chấm của người dùng
        /// </summary>
        [HttpGet("history")]
        public async Task<IActionResult> GetHistory()
        {
            // Tương lai bạn sẽ gọi _writingService.GetUserSubmissionsAsync(userId) ở đây
            return Ok(new { message = "Tính năng lịch sử đang được phát triển." });
        }
    }
}