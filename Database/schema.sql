-- ============================================
-- Magic English Database Schema
-- SQL Server Database Creation Script
-- ============================================

-- Create Database
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'MagicEnglishDB')
BEGIN
    DROP DATABASE MagicEnglishDB;
END
GO

CREATE DATABASE MagicEnglishDB;
GO

USE MagicEnglishDB;
GO

-- ============================================
-- Users Table
-- ============================================
CREATE TABLE Users (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    Email NVARCHAR(256) NOT NULL UNIQUE,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE()
);

-- Create index on Email for faster lookups
CREATE INDEX idx_Users_Email ON Users(Email);

-- ============================================
-- Vocabularies Table
-- ============================================
CREATE TABLE Vocabularies (
    Id INT PRIMARY KEY IDENTITY(1,1),
    UserId INT NOT NULL,
    Word NVARCHAR(100) NOT NULL,
    IPA NVARCHAR(100) NULL,
    Meaning NVARCHAR(500) NOT NULL,
    PartOfSpeech NVARCHAR(50) NULL,
    Example NVARCHAR(500) NULL,
    CEFRLevel NVARCHAR(2) DEFAULT 'A1',
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    LastReviewedAt DATETIME2 NULL,
    ReviewCount INT DEFAULT 0,
    FOREIGN KEY (UserId) REFERENCES Users(Id) ON DELETE CASCADE
);

-- Create indexes for faster queries
CREATE INDEX idx_Vocabularies_UserId ON Vocabularies(UserId);
CREATE INDEX idx_Vocabularies_CreatedAt ON Vocabularies(CreatedAt);
CREATE INDEX idx_Vocabularies_CEFRLevel ON Vocabularies(CEFRLevel);

-- ============================================
-- GrammarChecks Table
-- ============================================
CREATE TABLE GrammarChecks (
    Id INT PRIMARY KEY IDENTITY(1,1),
    UserId INT NOT NULL,
    OriginalText NVARCHAR(2000) NOT NULL,
    Score DECIMAL(5,2) NOT NULL,
    Errors NVARCHAR(MAX) NULL,
    Suggestions NVARCHAR(MAX) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FOREIGN KEY (UserId) REFERENCES Users(Id) ON DELETE CASCADE
);

-- Create indexes
CREATE INDEX idx_GrammarChecks_UserId ON GrammarChecks(UserId);
CREATE INDEX idx_GrammarChecks_CreatedAt ON GrammarChecks(CreatedAt);

-- ============================================
-- StudyActivities Table
-- ============================================
CREATE TABLE StudyActivities (
    Id INT PRIMARY KEY IDENTITY(1,1),
    UserId INT NOT NULL,
    ActivityType NVARCHAR(50) NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FOREIGN KEY (UserId) REFERENCES Users(Id) ON DELETE CASCADE
);

-- Create indexes
CREATE INDEX idx_StudyActivities_UserId ON StudyActivities(UserId);
CREATE INDEX idx_StudyActivities_CreatedAt ON StudyActivities(CreatedAt);
CREATE INDEX idx_StudyActivities_UserIdCreatedAt ON StudyActivities(UserId, CreatedAt);

-- ============================================
-- Streaks Table
-- ============================================
CREATE TABLE Streaks (
    Id INT PRIMARY KEY IDENTITY(1,1),
    UserId INT NOT NULL UNIQUE,
    CurrentStreak INT DEFAULT 0,
    LongestStreak INT DEFAULT 0,
    LastStudyDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    Badge3Days INT DEFAULT 0,
    Badge7Days INT DEFAULT 0,
    Badge30Days INT DEFAULT 0,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FOREIGN KEY (UserId) REFERENCES Users(Id) ON DELETE CASCADE
);

-- Create index
CREATE INDEX idx_Streaks_UserId ON Streaks(UserId);

-- ============================================
-- Create Views for Analytics
-- ============================================

-- View: User Statistics Summary
CREATE VIEW vw_UserStatistics AS
SELECT 
    u.Id,
    u.Name,
    u.Email,
    COALESCE(COUNT(DISTINCT v.Id), 0) AS TotalVocabulary,
    COALESCE(COUNT(DISTINCT gc.Id), 0) AS TotalGrammarChecks,
    COALESCE(s.CurrentStreak, 0) AS CurrentStreak,
    COALESCE(s.LongestStreak, 0) AS LongestStreak,
    u.CreatedAt
FROM Users u
LEFT JOIN Vocabularies v ON u.Id = v.UserId
LEFT JOIN GrammarChecks gc ON u.Id = gc.UserId
LEFT JOIN Streaks s ON u.Id = s.UserId
GROUP BY u.Id, u.Name, u.Email, u.CreatedAt, s.CurrentStreak, s.LongestStreak;

-- View: Daily Activity Summary
CREATE VIEW vw_DailyActivity AS
SELECT 
    UserId,
    CAST(CreatedAt AS DATE) AS ActivityDate,
    SUM(CASE WHEN ActivityType = 'Vocabulary' THEN 1 ELSE 0 END) AS VocabularyCount,
    SUM(CASE WHEN ActivityType = 'Grammar' THEN 1 ELSE 0 END) AS GrammarCount,
    COUNT(*) AS TotalActivities
FROM StudyActivities
GROUP BY UserId, CAST(CreatedAt AS DATE);

-- View: CEFR Level Distribution
CREATE VIEW vw_CEFRDistribution AS
SELECT 
    UserId,
    CEFRLevel,
    COUNT(*) AS WordCount
FROM Vocabularies
GROUP BY UserId, CEFRLevel;

-- View: Part of Speech Distribution
CREATE VIEW vw_PartOfSpeechDistribution AS
SELECT 
    UserId,
    PartOfSpeech,
    COUNT(*) AS WordCount
FROM Vocabularies
WHERE PartOfSpeech IS NOT NULL
GROUP BY UserId, PartOfSpeech;

-- ============================================
-- Database Setup Complete
-- ============================================
PRINT 'Magic English Database Created Successfully!';
