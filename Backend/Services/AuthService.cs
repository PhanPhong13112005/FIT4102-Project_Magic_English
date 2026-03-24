using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Backend.Data;
using Backend.DTOs;
using Backend.Models;
using Microsoft.IdentityModel.Tokens;
using Microsoft.EntityFrameworkCore;

namespace Backend.Services
{
    public interface IAuthService
    {
        Task<AuthResponse> RegisterAsync(RegisterRequest request);
        Task<AuthResponse> LoginAsync(LoginRequest request);
        string GenerateJwtToken(User user);
    }

    public class AuthService : IAuthService
    {
        private readonly AppDbContext _context;
        private readonly IConfiguration _configuration;
        private readonly ILogger<AuthService> _logger;

        public AuthService(AppDbContext context, IConfiguration configuration, ILogger<AuthService> logger)
        {
            _context = context;
            _configuration = configuration;
            _logger = logger;
        }

        public async Task<AuthResponse> RegisterAsync(RegisterRequest request)
        {
            try
            {
                // Validate input
                if (string.IsNullOrWhiteSpace(request.Email) ||
                    string.IsNullOrWhiteSpace(request.Username) ||
                    string.IsNullOrWhiteSpace(request.Password) ||
                    string.IsNullOrWhiteSpace(request.FullName))
                {
                    return new AuthResponse
                    {
                        Success = false,
                        Message = "Tất cả các trường là bắt buộc"
                    };
                }

                // Check if email already exists
                var existingEmail = await _context.Users.FirstOrDefaultAsync(u => u.Email == request.Email);
                if (existingEmail != null)
                {
                    return new AuthResponse
                    {
                        Success = false,
                        Message = "Email đã được đăng ký"
                    };
                }

                // Check if username already exists
                var existingUsername = await _context.Users.FirstOrDefaultAsync(u => u.Username == request.Username);
                if (existingUsername != null)
                {
                    return new AuthResponse
                    {
                        Success = false,
                        Message = "Username đã được sử dụng"
                    };
                }

                // Validate password strength
                if (request.Password.Length < 6)
                {
                    return new AuthResponse
                    {
                        Success = false,
                        Message = "Mật khẩu phải có ít nhất 6 ký tự."
                    };
                }

                // Create new user
                var user = new User
                {
                    Email = request.Email,
                    Username = request.Username,
                    FullName = request.FullName,
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow,
                    IsActive = true
                };

                // Create user stats
                var userStats = new UserStats
                {
                    User = user,
                    TotalVocabularyCount = 0,
                    CurrentStreak = 0,
                    LongestStreak = 0,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };

                _context.Users.Add(user);
                _context.UserStats.Add(userStats);
                await _context.SaveChangesAsync();

                _logger.LogInformation($"User registered successfully: {user.Email}");

                var token = GenerateJwtToken(user);
                var tokenExpiration = DateTime.UtcNow.AddHours(24);

                return new AuthResponse
                {
                    Success = true,
                    Message = "Người dùng đã đăng ký thành công",
                    Data = new AuthResponseData
                    {
                        UserId = user.Id,
                        Email = user.Email,
                        Username = user.Username,
                        FullName = user.FullName,
                        Token = token,
                        TokenExpiration = tokenExpiration
                    }
                };
            }
            catch (Exception ex)
            {
                _logger.LogError($"Registration error: {ex.Message}");
                return new AuthResponse
                {
                    Success = false,
                    Message = "Người dùng đã đăng ký thất bại"
                };
            }
        }

        public async Task<AuthResponse> LoginAsync(LoginRequest request)
        {
            try
            {
                // Validate input
                if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
                {
                    return new AuthResponse
                    {
                        Success = false,
                        Message = "Cần có email và mật khẩu."
                    };
                }

                // Find user by email
                var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == request.Email);
                if (user == null)
                {
                    return new AuthResponse
                    {
                        Success = false,
                        Message = "Email hoặc mật khẩu không hợp lệ"
                    };
                }

                // Check if user is active
                if (!user.IsActive)
                {
                    return new AuthResponse
                    {
                        Success = false,
                        Message = "Tài khoản người dùng đã bị vô hiệu hóa"
                    };
                }

                // Verify password
                if (!BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
                {
                    return new AuthResponse
                    {
                        Success = false,
                        Message = "Email hoặc mật khẩu không hợp lệ"
                    };
                }

                _logger.LogInformation($"User logged in successfully: {user.Email}");

                var token = GenerateJwtToken(user);
                var tokenExpiration = DateTime.UtcNow.AddHours(24);

                return new AuthResponse
                {
                    Success = true,
                    Message = "Đăng nhập thành công",
                    Data = new AuthResponseData
                    {
                        UserId = user.Id,
                        Email = user.Email,
                        Username = user.Username,
                        FullName = user.FullName,
                        Token = token,
                        TokenExpiration = tokenExpiration
                    }
                };
            }
            catch (Exception ex)
            {
                _logger.LogError($"Login error: {ex.Message}");
                return new AuthResponse
                {
                    Success = false,
                    Message = "Đăng nhập thất bại"
                };
            }
        }

        public string GenerateJwtToken(User user)
        {
            var jwtSettings = _configuration.GetSection("JwtSettings");
            var secretKey = jwtSettings["SecretKey"] ?? throw new InvalidOperationException("JWT SecretKey not configured");
            var issuer = jwtSettings["Issuer"] ?? "MagicEnglish";
            var audience = jwtSettings["Audience"] ?? "MagicEnglishUsers";
            var expirationHours = int.Parse(jwtSettings["ExpirationHours"] ?? "24");

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey));
            var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var claims = new[]
            {
                new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                new Claim(ClaimTypes.Email, user.Email),
                new Claim(ClaimTypes.Name, user.Username),
                new Claim("FullName", user.FullName)
            };

            var token = new JwtSecurityToken(
                issuer: issuer,
                audience: audience,
                claims: claims,
                expires: DateTime.UtcNow.AddHours(expirationHours),
                signingCredentials: credentials
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}
