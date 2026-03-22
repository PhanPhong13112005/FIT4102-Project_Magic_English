-- ============================================
-- Magic English Database - Seed Data
-- Initial test data for development
-- ============================================

USE MagicEnglishDB;
GO

-- Insert sample users
INSERT INTO Users (Name, Email, CreatedAt) VALUES
('John Doe', 'john@example.com', GETUTCDATE()),
('Jane Smith', 'jane@example.com', GETUTCDATE()),
('Mike Johnson', 'mike@example.com', GETUTCDATE());

GO

-- Insert sample vocabularies for user 1
INSERT INTO Vocabularies (UserId, Word, IPA, Meaning, PartOfSpeech, Example, CEFRLevel, CreatedAt, ReviewCount)
VALUES
(1, 'Serendipity', '/ˌserənˈdɪpɪti/', 'Sự tình cờ may mắn', 'Noun', 'Finding that old photo was pure serendipity.', 'C1', GETUTCDATE(), 3),
(1, 'Eloquent', '/ˈeləkwənt/', 'Nói chuyện lưu loát, đắc lực', 'Adjective', 'The speaker gave an eloquent presentation.', 'B2', GETUTCDATE(), 2),
(1, 'Ephemeral', '/ɪˈfem(ə)rəl/', 'Thoáng qua, ngắn chốc', 'Adjective', 'The beauty of cherry blossoms is ephemeral.', 'C2', GETUTCDATE(), 1),
(1, 'Pragmatic', '/praɡˈmatɪk/', 'Thực tế, thiết thực', 'Adjective', 'We need a pragmatic approach to solve this problem.', 'B2', GETUTCDATE(), 4),
(1, 'Meticulous', '/məˈtɪkjʊləs/', 'Tỉ mỉ, chu đáo', 'Adjective', 'She did a meticulous job on the project.', 'C1', GETUTCDATE(), 2);

-- Insert sample vocabularies for user 2
INSERT INTO Vocabularies (UserId, Word, IPA, Meaning, PartOfSpeech, Example, CEFRLevel, CreatedAt, ReviewCount)
VALUES
(2, 'Ambitious', '/amˈbɪʃəs/', 'Tham vọng', 'Adjective', 'She has ambitious goals for her career.', 'A2', GETUTCDATE(), 1),
(2, 'Benevolent', '/bəˈnevələnt/', 'Nhân từ, tốt bụng', 'Adjective', 'The benevolent king helped the poor people.', 'B2', DATE_SUB(GETUTCDATE(), INTERVAL 1 DAY), 2),
(2, 'Candid', '/ˈkandɪd/', 'Thẳng thắn, trung thực', 'Adjective', 'He gave a candid opinion about the situation.', 'B1', DATE_SUB(GETUTCDATE(), INTERVAL 2 DAY), 1);

GO

-- Insert sample grammar checks for user 1
INSERT INTO GrammarChecks (UserId, OriginalText, Score, Errors, Suggestions, CreatedAt)
VALUES
(1, 'She go to the store yesterday.', 7.0, '[{"type":"Grammar","description":"Subject-verb agreement error","position":4,"suggestedFix":"goes"}]', '["Use past tense for yesterday","Subject is third person singular"]', GETUTCDATE()),
(1, 'The cat sitting on the mat.', 6.5, '[{"type":"Grammar","description":"Missing auxiliary verb","position":8,"suggestedFix":"is sitting"}]', '["Add auxiliary verb for continuous tense"]', DATE_SUB(GETUTCDATE(), INTERVAL 1 DAY));

GO

-- Insert sample study activities for user 1
DECLARE @UserId INT = 1;
DECLARE @DateOffset INT = 0;

WHILE @DateOffset < 30
BEGIN
    INSERT INTO StudyActivities (UserId, ActivityType, CreatedAt)
    VALUES
    (@UserId, 'Vocabulary', DATEADD(DAY, -@DateOffset, GETUTCDATE())),
    (@UserId, 'Grammar', DATEADD(DAY, -@DateOffset, GETUTCDATE()));
    
    SET @DateOffset = @DateOffset + 1;
END

GO

-- Insert sample streaks
INSERT INTO Streaks (UserId, CurrentStreak, LongestStreak, LastStudyDate, Badge3Days, Badge7Days, Badge30Days, CreatedAt, UpdatedAt)
VALUES
(1, 15, 20, GETUTCDATE(), 1, 1, 0, GETUTCDATE(), GETUTCDATE()),
(2, 5, 10, GETUTCDATE(), 0, 0, 0, GETUTCDATE(), GETUTCDATE()),
(3, 0, 5, DATE_SUB(GETUTCDATE(), INTERVAL 3 DAY), 0, 0, 0, GETUTCDATE(), GETUTCDATE());

GO

-- ============================================
-- Seed Data Insertion Complete
-- ============================================
PRINT 'Sample Data Inserted Successfully!';

-- Display summary
SELECT 'Total Users:' AS [Summary], COUNT(*) AS [Count] FROM Users
UNION ALL
SELECT 'Total Vocabularies', COUNT(*) FROM Vocabularies
UNION ALL
SELECT 'Total Grammar Checks', COUNT(*) FROM GrammarChecks
UNION ALL
SELECT 'Total Study Activities', COUNT(*) FROM StudyActivities
UNION ALL
SELECT 'Total Streaks', COUNT(*) FROM Streaks;
