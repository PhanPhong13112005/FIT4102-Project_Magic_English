using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using MagicEnglishAPI.Data;
using MagicEnglishAPI.DTOs;
using MagicEnglishAPI.Models;

namespace MagicEnglishAPI.Services;

/// <summary>
/// Service for user management operations
/// </summary>
public class UserService : IUserService
{
    private readonly MagicEnglishDbContext _context;
    private readonly ILogger<UserService> _logger;

    public UserService(MagicEnglishDbContext context, ILogger<UserService> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task<UserDto> CreateUserAsync(CreateUserDto dto, CancellationToken cancellationToken = default)
    {
        try
        {
            _logger.LogInformation("Creating user with email: {Email}", dto.Email);

            // Check if email already exists
            var existingUser = await _context.Users
                .FirstOrDefaultAsync(u => u.Email == dto.Email, cancellationToken);

            if (existingUser != null)
            {
                throw new InvalidOperationException($"User with email {dto.Email} already exists");
            }

            var user = new User
            {
                Name = dto.Name,
                Email = dto.Email,
                CreatedAt = DateTime.UtcNow
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync(cancellationToken);

            // Create initial streak for user
            var streak = new Streak
            {
                UserId = user.Id,
                CurrentStreak = 0,
                LongestStreak = 0,
                LastStudyDate = DateTime.UtcNow,
                CreatedAt = DateTime.UtcNow
            };
            _context.Streaks.Add(streak);
            await _context.SaveChangesAsync(cancellationToken);

            _logger.LogInformation("Successfully created user {UserId} with email: {Email}", user.Id, dto.Email);

            return MapToDto(user);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating user with email: {Email}", dto.Email);
            throw;
        }
    }

    public async Task<UserDto?> GetUserAsync(int userId, CancellationToken cancellationToken = default)
    {
        try
        {
            var user = await _context.Users.FindAsync(new object[] { userId }, cancellationToken: cancellationToken);
            return user != null ? MapToDto(user) : null;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting user {UserId}", userId);
            throw;
        }
    }

    public async Task<UserDto?> GetUserByEmailAsync(string email, CancellationToken cancellationToken = default)
    {
        try
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email == email, cancellationToken);

            return user != null ? MapToDto(user) : null;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting user by email: {Email}", email);
            throw;
        }
    }

    public async Task<List<UserDto>> ListUsersAsync(CancellationToken cancellationToken = default)
    {
        try
        {
            var users = await _context.Users
                .OrderByDescending(u => u.CreatedAt)
                .ToListAsync(cancellationToken);

            return users.Select(MapToDto).ToList();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error listing users");
            throw;
        }
    }

    public async Task<UserDto> UpdateUserAsync(int userId, CreateUserDto dto, CancellationToken cancellationToken = default)
    {
        try
        {
            _logger.LogInformation("Updating user {UserId}", userId);

            var user = await _context.Users.FindAsync(new object[] { userId }, cancellationToken: cancellationToken);
            if (user == null)
            {
                throw new InvalidOperationException($"User with ID {userId} not found");
            }

            user.Name = dto.Name;
            user.Email = dto.Email;

            _context.Users.Update(user);
            await _context.SaveChangesAsync(cancellationToken);

            _logger.LogInformation("Successfully updated user {UserId}", userId);

            return MapToDto(user);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating user {UserId}", userId);
            throw;
        }
    }

    private UserDto MapToDto(User user)
    {
        return new UserDto
        {
            Id = user.Id,
            Name = user.Name,
            Email = user.Email,
            CreatedAt = user.CreatedAt
        };
    }
}
