using MagicEnglishAPI.DTOs;

namespace MagicEnglishAPI.Services;

/// <summary>
/// Interface for user management operations
/// </summary>
public interface IUserService
{
    /// <summary>
    /// Create a new user
    /// </summary>
    Task<UserDto> CreateUserAsync(CreateUserDto dto, CancellationToken cancellationToken = default);

    /// <summary>
    /// Get user by ID
    /// </summary>
    Task<UserDto?> GetUserAsync(int userId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Get user by email
    /// </summary>
    Task<UserDto?> GetUserByEmailAsync(string email, CancellationToken cancellationToken = default);

    /// <summary>
    /// List all users
    /// </summary>
    Task<List<UserDto>> ListUsersAsync(CancellationToken cancellationToken = default);

    /// <summary>
    /// Update user information
    /// </summary>
    Task<UserDto> UpdateUserAsync(int userId, CreateUserDto dto, CancellationToken cancellationToken = default);
}
