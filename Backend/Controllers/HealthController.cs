using Microsoft.AspNetCore.Mvc;

namespace Backend.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class HealthController : ControllerBase
    {
        private readonly ILogger<HealthController> _logger;

        public HealthController(ILogger<HealthController> logger)
        {
            _logger = logger;
        }

        [HttpGet]
        public IActionResult Get()
        {
            _logger.LogInformation("Health check called");
            return Ok(new { status = "healthy", timestamp = DateTime.UtcNow });
        }

        [HttpGet("live")]
        public IActionResult Live()
        {
            return Ok(new { status = "alive" });
        }

        [HttpGet("ready")]
        public IActionResult Ready()
        {
            return Ok(new { status = "ready" });
        }
    }
}
