using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using MagicEnglishAPI.Data;
using MagicEnglishAPI.DTOs;
using MagicEnglishAPI.Models;

namespace MagicEnglishAPI.Services;

/// <summary>
/// Service for statistics and streak operations
/// </summary>
public class StatisticsService : IStatisticsService
{
    private readonly MagicEnglishDbContext _context;
    private readonly ILogger<StatisticsService> _logger;
    private readonly IOllamaService _ollamaService;

    public StatisticsService(MagicEnglishDbContext context, ILogger<StatisticsService> logger, IOllamaService ollamaService)
    {
        _context = context;
        _logger = logger;
        _ollamaService = ollamaService;
    }

    public async Task<DashboardDto> GetDashboardAsync(int userId, CancellationToken cancellationToken = default)
    {
        try
        {
            _logger.LogInformation("Getting dashboard for user {UserId}", userId);

            var user = await _context.Users.FindAsync(new object[] { userId }, cancellationToken: cancellationToken);
            if (user == null)
            {
                throw new InvalidOperationException($"User with ID {userId} not found");
            }

            var vocabularyCount = await _context.Vocabularies
                .CountAsync(v => v.UserId == userId, cancellationToken);

            var streak = await _context.Streaks
                .FirstOrDefaultAsync(s => s.UserId == userId, cancellationToken);

            var todayActivityCount = await _context.StudyActivities
                .CountAsync(a => a.UserId == userId && a.CreatedAt.Date == DateTime.UtcNow.Date, cancellationToken);

            var vocabularyStats = await GetVocabularyStatisticsAsync(userId, cancellationToken);
            var activityTrend = await GetActivityTrendAsync(userId, 30, cancellationToken);

            var dashboard = new DashboardDto
            {
                TotalVocabularyLearned = vocabularyCount,
                CurrentStreak = streak?.CurrentStreak ?? 0,
                TodayActivityCount = todayActivityCount,
                Streak = streak != null ? MapStreakToDto(streak) : new StreakDto(),
                VocabularyStats = vocabularyStats,
                ActivityTrend = activityTrend
            };

            return dashboard;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting dashboard for user {UserId}", userId);
            throw;
        }
    }

    public async Task<StreakDto> GetStreakAsync(int userId, CancellationToken cancellationToken = default)
    {
        try
        {
            var streak = await _context.Streaks
                .FirstOrDefaultAsync(s => s.UserId == userId, cancellationToken);

            if (streak == null)
            {
                // Create initial streak if not exists
                streak = new Streak
                {
                    UserId = userId,
                    CurrentStreak = 0,
                    LongestStreak = 0,
                    LastStudyDate = DateTime.UtcNow,
                    CreatedAt = DateTime.UtcNow
                };
                _context.Streaks.Add(streak);
                await _context.SaveChangesAsync(cancellationToken);
            }

            return MapStreakToDto(streak);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting streak for user {UserId}", userId);
            throw;
        }
    }

    public async Task<StreakDto> UpdateStreakAsync(int userId, CancellationToken cancellationToken = default)
    {
        try
        {
            _logger.LogInformation("Updating streak for user {UserId}", userId);

            var streak = await _context.Streaks
                .FirstOrDefaultAsync(s => s.UserId == userId, cancellationToken);

            if (streak == null)
            {
                // Create new streak
                streak = new Streak
                {
                    UserId = userId,
                    CurrentStreak = 1,
                    LongestStreak = 1,
                    LastStudyDate = DateTime.UtcNow,
                    CreatedAt = DateTime.UtcNow
                };
                _context.Streaks.Add(streak);
            }
            else
            {
                var today = DateTime.UtcNow.Date;
                var lastStudyDate = streak.LastStudyDate.Date;

                if (lastStudyDate == today)
                {
                    // Already studied today, no need to update
                    _logger.LogInformation("User {UserId} already studied today", userId);
                }
                else if ((today - lastStudyDate).TotalDays == 1)
                {
                    // Studied yesterday, continue the streak
                    streak.CurrentStreak++;
                    streak.LastStudyDate = DateTime.UtcNow;

                    if (streak.CurrentStreak > streak.LongestStreak)
                    {
                        streak.LongestStreak = streak.CurrentStreak;
                    }

                    // Check for badges
                    if (streak.CurrentStreak >= 3 && streak.Badge3Days == 0)
                    {
                        streak.Badge3Days = 1;
                        _logger.LogInformation("User {UserId} earned 3-day badge", userId);
                    }
                    if (streak.CurrentStreak >= 7 && streak.Badge7Days == 0)
                    {
                        streak.Badge7Days = 1;
                        _logger.LogInformation("User {UserId} earned 7-day badge", userId);
                    }
                    if (streak.CurrentStreak >= 30 && streak.Badge30Days == 0)
                    {
                        streak.Badge30Days = 1;
                        _logger.LogInformation("User {UserId} earned 30-day badge", userId);
                    }
                }
                else
                {
                    // Streak broken, reset
                    streak.CurrentStreak = 1;
                    streak.LastStudyDate = DateTime.UtcNow;
                    _logger.LogInformation("Streak broken for user {UserId}, resetting to 1", userId);
                }

                streak.UpdatedAt = DateTime.UtcNow;
            }

            await _context.SaveChangesAsync(cancellationToken);

            _logger.LogInformation("Successfully updated streak for user {UserId}", userId);

            return MapStreakToDto(streak);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating streak for user {UserId}", userId);
            throw;
        }
    }

    public async Task<List<DailyActivityDto>> GetActivityTrendAsync(int userId, int days = 30, CancellationToken cancellationToken = default)
    {
        try
        {
            var startDate = DateTime.UtcNow.AddDays(-days).Date;
            var endDate = DateTime.UtcNow.Date.AddDays(1);

            var activities = await _context.StudyActivities
                .Where(a => a.UserId == userId && a.CreatedAt >= startDate && a.CreatedAt < endDate)
                .GroupBy(a => a.CreatedAt.Date)
                .Select(g => new
                {
                    Date = g.Key,
                    VocabularyCount = g.Count(a => a.ActivityType == ActivityType.Vocabulary),
                    GrammarCount = g.Count(a => a.ActivityType == ActivityType.Grammar)
                })
                .OrderBy(x => x.Date)
                .ToListAsync(cancellationToken);

            // Fill in missing dates
            var result = new List<DailyActivityDto>();
            var currentDate = startDate;
            var activityDict = activities.ToDictionary(a => a.Date);

            while (currentDate <= DateTime.UtcNow.Date)
            {
                if (activityDict.TryGetValue(currentDate, out var activity))
                {
                    result.Add(new DailyActivityDto
                    {
                        Date = currentDate,
                        VocabularyCount = activity.VocabularyCount,
                        GrammarCount = activity.GrammarCount,
                        TotalCount = activity.VocabularyCount + activity.GrammarCount
                    });
                }
                else
                {
                    result.Add(new DailyActivityDto
                    {
                        Date = currentDate,
                        VocabularyCount = 0,
                        GrammarCount = 0,
                        TotalCount = 0
                    });
                }
                currentDate = currentDate.AddDays(1);
            }

            return result;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting activity trend for user {UserId}", userId);
            throw;
        }
    }

    private StreakDto MapStreakToDto(Streak streak)
    {
        return new StreakDto
        {
            Id = streak.Id,
            CurrentStreak = streak.CurrentStreak,
            LongestStreak = streak.LongestStreak,
            LastStudyDate = streak.LastStudyDate,
            Has3DaysBadge = streak.Badge3Days == 1,
            Has7DaysBadge = streak.Badge7Days == 1,
            Has30DaysBadge = streak.Badge30Days == 1
        };
    }

    private async Task<VocabularyStatisticsDto> GetVocabularyStatisticsAsync(int userId, CancellationToken cancellationToken = default)
    {
        var vocabularies = await _context.Vocabularies
            .Where(v => v.UserId == userId)
            .ToListAsync(cancellationToken);

        return new VocabularyStatisticsDto
        {
            TotalWords = vocabularies.Count,
            PartOfSpeechDistribution = vocabularies
                .GroupBy(v => v.PartOfSpeech)
                .ToDictionary(g => g.Key, g => g.Count()),
            CEFRLevelDistribution = vocabularies
                .GroupBy(v => v.CEFRLevel)
                .ToDictionary(g => g.Key, g => g.Count())
        };
    }

    public async Task<AdvancedAnalysisDto> GetAdvancedAnalysisAsync(int userId, CancellationToken cancellationToken = default)
    {
        try
        {
            _logger.LogInformation("Getting advanced analysis for user {UserId}", userId);

            var user = await _context.Users.FindAsync(new object[] { userId }, cancellationToken: cancellationToken);
            if (user == null)
            {
                throw new InvalidOperationException($"User with ID {userId} not found");
            }

            // Call Ollama API for advanced analysis
            var model = "llama2:13b"; // Example model, replace with actual model if needed
            var prompt = "Provide advanced analysis for user data."; // Example prompt, customize as needed
            var analysisResult = await _ollamaService.GetAdvancedAnalysisAsync(userId, model, prompt, cancellationToken);

            if (analysisResult == null)
            {
                _logger.LogError("Failed to retrieve advanced analysis for user {UserId}", userId);
                throw new InvalidOperationException("Failed to retrieve advanced analysis.");
            }

            return new AdvancedAnalysisDto
            {
                UserId = userId,
                AnalysisDetails = analysisResult.Details,
                Recommendations = analysisResult.Recommendations
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting advanced analysis for user {UserId}", userId);
            throw;
        }
    }
}
