using Backend.Data;
using Backend.DTOs;
using Backend.Models;
using Microsoft.EntityFrameworkCore;

namespace Backend.Services
{
    public interface IStatsService
    {
        Task<StatsResponse> GetStatsAsync(int userId);
        Task<DashboardResponse> GetDashboardAsync(int userId);
        Task RecordVocabularyAddedAsync(int userId);
        Task RecordWritingSubmissionAsync(int userId);
        Task UpdateStreakAsync(int userId);
    }

    public class StatsService : IStatsService
    {
        private readonly AppDbContext _dbContext;

        public StatsService(AppDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<StatsResponse> GetStatsAsync(int userId)
        {
            var stats = await _dbContext.UserStats.FirstOrDefaultAsync(s => s.UserId == userId);
            if (stats == null)
            {
                stats = new UserStats
                {
                    UserId = userId,
                    TotalVocabularyCount = 0,
                    CurrentStreak = 0,
                    LongestStreak = 0,
                    LastActivityDate = DateTime.UtcNow,
                    CreatedAt = DateTime.UtcNow
                };
                _dbContext.UserStats.Add(stats);
                await _dbContext.SaveChangesAsync();
            }

            var achievements = GetAchievements(stats);

            return new StatsResponse
            {
                TotalVocabularyCount = stats.TotalVocabularyCount,
                CurrentStreak = stats.CurrentStreak,
                LongestStreak = stats.LongestStreak,
                LastActivityDate = stats.LastActivityDate,
                Achievements = achievements
            };
        }

        public async Task<DashboardResponse> GetDashboardAsync(int userId)
        {
            var stats = await GetStatsAsync(userId);

            // Get word type distribution (user's vocabularies only)
            var wordTypeDistribution = await _dbContext.Vocabularies
                .Where(v => v.UserId == userId)
                .GroupBy(v => v.WordType)
                .Select(g => new WordTypeDistributionResponse
                {
                    WordType = g.Key,
                    Count = g.Count()
                })
                .ToListAsync();

            // Get CEFR level distribution (user's vocabularies only)
            var cefrDistribution = await _dbContext.Vocabularies
                .Where(v => v.UserId == userId)
                .GroupBy(v => v.CEFRLevel)
                .Select(g => new CEFRLevelDistributionResponse
                {
                    Level = g.Key,
                    Count = g.Count()
                })
                .OrderBy(x => GetCEFROrderValue(x.Level))
                .ToListAsync();

            return new DashboardResponse
            {
                Stats = stats,
                WordTypeDistribution = wordTypeDistribution,
                CEFRDistribution = cefrDistribution
            };
        }

        public async Task RecordVocabularyAddedAsync(int userId)
        {
            await RecordActivityAsync(userId);
        }

        public async Task RecordWritingSubmissionAsync(int userId)
        {
            await RecordActivityAsync(userId);
        }

        public async Task UpdateStreakAsync(int userId)
        {
            var stats = await _dbContext.UserStats.FirstOrDefaultAsync(s => s.UserId == userId);
            if (stats == null) return;

            var today = DateTime.UtcNow.Date;
            var lastActivityDate = stats.LastActivityDate.Date;

            if (lastActivityDate == today)
            {
                // Already counted today
                return;
            }

            if (lastActivityDate == today.AddDays(-1))
            {
                // Streak continues
                stats.CurrentStreak++;
                if (stats.CurrentStreak > stats.LongestStreak)
                {
                    stats.LongestStreak = stats.CurrentStreak;
                }
            }
            else if (lastActivityDate < today.AddDays(-1))
            {
                // Streak broken
                stats.CurrentStreak = 1;
            }

            stats.LastActivityDate = DateTime.UtcNow;
            stats.UpdatedAt = DateTime.UtcNow;
            await _dbContext.SaveChangesAsync();
        }

        private async Task RecordActivityAsync(int userId)
        {
            var today = DateTime.UtcNow.Date;
            var existingActivity = await _dbContext.DailyActivities
                .FirstOrDefaultAsync(d => d.UserId == userId && d.ActivityDate.Date == today);

            if (existingActivity != null)
            {
                existingActivity.IsLearningDay = true;
            }
            else
            {
                var dailyActivity = new DailyActivity
                {
                    UserId = userId,
                    ActivityDate = today,
                    VocabularyAdded = 0,
                    WritingSubmissions = 0,
                    IsLearningDay = true
                };
                _dbContext.DailyActivities.Add(dailyActivity);
            }

            // Update total vocabulary count for this user
            var stats = await _dbContext.UserStats.FirstOrDefaultAsync(s => s.UserId == userId);
            if (stats == null)
            {
                stats = new UserStats
                {
                    UserId = userId,
                    TotalVocabularyCount = 0,
                    CurrentStreak = 1,
                    LongestStreak = 1,
                    LastActivityDate = DateTime.UtcNow,
                    CreatedAt = DateTime.UtcNow
                };
                _dbContext.UserStats.Add(stats);
            }
            else
            {
                stats.TotalVocabularyCount = await _dbContext.Vocabularies.Where(v => v.UserId == userId).CountAsync();
                stats.LastActivityDate = DateTime.UtcNow;
                stats.UpdatedAt = DateTime.UtcNow;

                // Update streak
                var lastActivityDate = stats.LastActivityDate.Date;
                var nowDate = DateTime.UtcNow.Date;

                if (lastActivityDate != nowDate)
                {
                    if (lastActivityDate == nowDate.AddDays(-1))
                    {
                        stats.CurrentStreak++;
                    }
                    else
                    {
                        stats.CurrentStreak = 1;
                    }

                    if (stats.CurrentStreak > stats.LongestStreak)
                    {
                        stats.LongestStreak = stats.CurrentStreak;
                    }
                }
            }

            await _dbContext.SaveChangesAsync();
        }

        private List<AchievementDto> GetAchievements(UserStats stats)
        {
            var achievements = new List<AchievementDto>
            {
                new AchievementDto
                {
                    Name = "3-Day Learner",
                    Description = "Complete 3 consecutive days of learning",
                    RequiredDays = 3,
                    Unlocked = stats.LongestStreak >= 3
                },
                new AchievementDto
                {
                    Name = "Week Warrior",
                    Description = "Complete 7 consecutive days of learning",
                    RequiredDays = 7,
                    Unlocked = stats.LongestStreak >= 7
                },
                new AchievementDto
                {
                    Name = "Month Master",
                    Description = "Complete 30 consecutive days of learning",
                    RequiredDays = 30,
                    Unlocked = stats.LongestStreak >= 30
                },
                new AchievementDto
                {
                    Name = "100-Word Club",
                    Description = "Learn 100 new words",
                    RequiredDays = 0,
                    Unlocked = stats.TotalVocabularyCount >= 100
                },
                new AchievementDto
                {
                    Name = "500-Word Elite",
                    Description = "Learn 500 new words",
                    RequiredDays = 0,
                    Unlocked = stats.TotalVocabularyCount >= 500
                }
            };

            return achievements;
        }

        private int GetCEFROrderValue(string level)
        {
            return level switch
            {
                "A1" => 1,
                "A2" => 2,
                "B1" => 3,
                "B2" => 4,
                "C1" => 5,
                "C2" => 6,
                _ => 0
            };
        }
    }
}
