using MagicEnglishAPI.DTOs;

namespace MagicEnglishAPI.Services;

/// <summary>
/// Interface for statistics and streak operations
/// </summary>
public interface IStatisticsService
{
    /// <summary>
    /// Get user dashboard data
    /// </summary>
    Task<DashboardDto> GetDashboardAsync(int userId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Get user's streak information
    /// </summary>
    Task<StreakDto> GetStreakAsync(int userId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Update streak (called after any study activity)
    /// </summary>
    Task<StreakDto> UpdateStreakAsync(int userId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Get activity trend for the last 30 days
    /// </summary>
    Task<List<DailyActivityDto>> GetActivityTrendAsync(int userId, int days = 30, CancellationToken cancellationToken = default);
}
