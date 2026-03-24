using Backend.Data;
using Backend.DTOs;
using Backend.Models;
using Microsoft.EntityFrameworkCore;

namespace Backend.Services
{
    // 1. Định nghĩa Interface ngay tại đầu file
    public interface IStatsService
    {
        Task<StatsResponse> GetStatsAsync(int userId);
        Task<DashboardResponse> GetDashboardAsync(int userId);
        Task RecordVocabularyAddedAsync(int userId);
        Task RecordWritingSubmissionAsync(int userId);
        Task UpdateStreakAsync(int userId);
    }

    // 2. Triển khai Class dịch vụ
    public class StatsService : IStatsService
    {
        private readonly AppDbContext _dbContext;

        public StatsService(AppDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<StatsResponse> GetStatsAsync(int userId)
{
    // 1. Đếm trực tiếp từ bảng Vocabularies để luôn chính xác 100%
    var actualVocabCount = await _dbContext.Vocabularies.CountAsync(v => v.UserId == userId);

    var stats = await _dbContext.UserStats.FirstOrDefaultAsync(s => s.UserId == userId);
    if (stats == null)
    {
        stats = new UserStats
        {
            UserId = userId,
            TotalVocabularyCount = actualVocabCount,
            CurrentStreak = 1,
            LongestStreak = 1,
            LastActivityDate = DateTime.UtcNow,
            CreatedAt = DateTime.UtcNow
        };
        _dbContext.UserStats.Add(stats);
        await _dbContext.SaveChangesAsync();
    }

    var achievements = GetAchievements(stats);

    return new StatsResponse
    {
        // Gán con số thực tế vừa đếm được thay vì lấy số 0 trong DB
        TotalVocabularyCount = actualVocabCount, 
        CurrentStreak = stats.CurrentStreak,
        LongestStreak = stats.LongestStreak,
        LastActivityDate = stats.LastActivityDate,
        Achievements = achievements
    };
}

    public async Task<DashboardResponse> GetDashboardAsync(int userId)
    {
        var stats = await GetStatsAsync(userId);

        var wordTypeDistribution = await _dbContext.Vocabularies
            .Where(v => v.UserId == userId)
            .GroupBy(v => v.WordType)
            .Select(g => new WordTypeDistributionResponse
            {
                WordType = g.Key,
                Count = g.Count()
            })
            .ToListAsync();

        // 2. SỬA LỖI LINQ: Lấy dữ liệu về bộ nhớ (AsEnumerable) trước khi sắp xếp
        var cefrDistribution = (await _dbContext.Vocabularies
            .Where(v => v.UserId == userId)
            .GroupBy(v => v.CEFRLevel)
            .Select(g => new CEFRLevelDistributionResponse
            {
                Level = g.Key,
                Count = g.Count()
            })
            .ToListAsync()) // Đưa dữ liệu ra khỏi SQL để C# xử lý hàm GetCEFROrderValue
            .OrderBy(x => GetCEFROrderValue(x.Level))
            .ToList();

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

            if (lastActivityDate == today) return;

            if (lastActivityDate == today.AddDays(-1))
            {
                stats.CurrentStreak++;
                if (stats.CurrentStreak > stats.LongestStreak)
                {
                    stats.LongestStreak = stats.CurrentStreak;
                }
            }
            else if (lastActivityDate < today.AddDays(-1))
            {
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
                var lastActivityDate = stats.LastActivityDate.Date;
                var nowDate = DateTime.UtcNow.Date;

                if (lastActivityDate != nowDate)
                {
                    if (lastActivityDate == nowDate.AddDays(-1)) stats.CurrentStreak++;
                    else stats.CurrentStreak = 1;

                    if (stats.CurrentStreak > stats.LongestStreak) stats.LongestStreak = stats.CurrentStreak;
                }
                stats.LastActivityDate = DateTime.UtcNow;
                stats.UpdatedAt = DateTime.UtcNow;
            }

            await _dbContext.SaveChangesAsync();
        }

        private List<AchievementDto> GetAchievements(UserStats stats)
        {
            return new List<AchievementDto>
            {
                new AchievementDto { Name = "3-Day Learner", Description = "Học liên tiếp 3 ngày", Unlocked = stats.LongestStreak >= 3 },
                new AchievementDto { Name = "Week Warrior", Description = "Học liên tiếp 7 ngày", Unlocked = stats.LongestStreak >= 7 },
                new AchievementDto { Name = "100-Word Club", Description = "Học được 100 từ mới", Unlocked = stats.TotalVocabularyCount >= 100 }
            };
        }

        private int GetCEFROrderValue(string level)
        {
            return level switch
            {
                "A1" => 1, "A2" => 2, "B1" => 3, "B2" => 4, "C1" => 5, "C2" => 6, _ => 0
            };
        }
    }
}