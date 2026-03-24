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
    public class VocabularyController : ControllerBase
    {
        private readonly IVocabularyService _vocabularyService;
        private readonly ILogger<VocabularyController> _logger;

        public VocabularyController(IVocabularyService vocabularyService, ILogger<VocabularyController> logger)
        {
            _vocabularyService = vocabularyService;
            _logger = logger;
        }

        private int GetUserId()
        {
            // 2. Trả về mặc định ID = 1 để logic Service không bị lỗi
            return 1; 

            /* Code thực tế khi chạy App Flutter:
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!int.TryParse(userIdClaim, out var userId))
                throw new UnauthorizedAccessException("User ID not found in token");
            return userId;
            */
        }

        [HttpPost("add")]
        public async Task<ActionResult<VocabularyDto>> AddVocabulary([FromBody] AddVocabularyRequest request)
        {
            try
            {
                var userId = GetUserId();
                var result = await _vocabularyService.AddVocabularyAsync(userId, request);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi thêm từ vựng");
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpGet("list")]
        public async Task<ActionResult<VocabularyListResponse>> GetAllVocabulary([FromQuery] int page = 1, [FromQuery] int pageSize = 20)
        {
            try
            {
                var userId = GetUserId();
                var result = await _vocabularyService.GetUserVocabulariesAsync(userId, page, pageSize);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi lấy danh sách từ vựng");
                return BadRequest(new { message = ex.Message });
            }
        }
        [HttpGet("{id}")]
        public async Task<ActionResult<VocabularyDto>> GetVocabularyById(int id)
        {
            try
            {
                var userId = GetUserId();
                var result = await _vocabularyService.GetVocabularyByIdAsync(userId, id);
                if (result == null)
                    return NotFound();

                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi lấy từ vựng");
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpGet("search")]
        public async Task<ActionResult<List<VocabularyDto>>> SearchVocabulary([FromQuery] string term)
        {
            try
            {
                if (string.IsNullOrEmpty(term))
                    return BadRequest(new { message = "Từ khóa tìm kiếm không được để trống." });

                var userId = GetUserId();
                var result = await _vocabularyService.SearchVocabularyAsync(userId, term);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi tìm kiếm từ vựng");
                return BadRequest(new { message = ex.Message });
            }
        }

    }
}
