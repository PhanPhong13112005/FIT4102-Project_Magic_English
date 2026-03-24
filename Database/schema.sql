-- Magic English Database Schema (PostgreSQL Version)

-- Xóa các bảng cũ nếu tồn tại để làm sạch dữ liệu
DROP VIEW IF EXISTS vw_PartOfSpeechDistribution;
DROP VIEW IF EXISTS vw_CEFRDistribution;
DROP VIEW IF EXISTS vw_DailyActivity;
DROP VIEW IF EXISTS vw_UserStatistics;

DROP TABLE IF EXISTS Streaks;
DROP TABLE IF EXISTS StudyActivities;
DROP TABLE IF EXISTS GrammarChecks;
DROP TABLE IF EXISTS Vocabularies;
DROP TABLE IF EXISTS "Users" CASCADE;

-- 1. Bảng Users
CREATE TABLE "Users" (
    Id SERIAL PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(256) NOT NULL UNIQUE,
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_Users_Email ON "Users"(Email);

-- 2. Bảng Vocabularies
CREATE TABLE Vocabularies (
    Id SERIAL PRIMARY KEY,
    UserId INT NOT NULL,
    Word VARCHAR(100) NOT NULL,
    IPA VARCHAR(100),
    Meaning VARCHAR(500) NOT NULL,
    PartOfSpeech VARCHAR(50),
    Example VARCHAR(500),
    CEFRLevel VARCHAR(2) DEFAULT 'A1',
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    LastReviewedAt TIMESTAMP,
    ReviewCount INT DEFAULT 0,
    CONSTRAINT FK_Vocabularies_Users FOREIGN KEY (UserId) REFERENCES "Users"(Id) ON DELETE CASCADE
);

CREATE INDEX idx_Vocabularies_UserId ON Vocabularies(UserId);
CREATE INDEX idx_Vocabularies_CEFRLevel ON Vocabularies(CEFRLevel);

-- 3. Bảng GrammarChecks
CREATE TABLE GrammarChecks (
    Id SERIAL PRIMARY KEY,
    UserId INT NOT NULL,
    OriginalText TEXT NOT NULL,
    Score DECIMAL(5,2) NOT NULL,
    Errors TEXT,
    Suggestions TEXT,
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_GrammarChecks_Users FOREIGN KEY (UserId) REFERENCES "Users"(Id) ON DELETE CASCADE
);

-- 4. Bảng StudyActivities
CREATE TABLE StudyActivities (
    Id SERIAL PRIMARY KEY,
    UserId INT NOT NULL,
    ActivityType VARCHAR(50) NOT NULL,
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_StudyActivities_Users FOREIGN KEY (UserId) REFERENCES "Users"(Id) ON DELETE CASCADE
);

-- 5. Bảng Streaks
CREATE TABLE Streaks (
    Id SERIAL PRIMARY KEY,
    UserId INT NOT NULL UNIQUE,
    CurrentStreak INT DEFAULT 0,
    LongestStreak INT DEFAULT 0,
    LastStudyDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Badge3Days INT DEFAULT 0,
    Badge7Days INT DEFAULT 0,
    Badge30Days INT DEFAULT 0,
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_Streaks_Users FOREIGN KEY (UserId) REFERENCES "Users"(Id) ON DELETE CASCADE
);

-- Tạo các View thống kê
CREATE VIEW vw_UserStatistics AS
SELECT 
    u.Id, u.Name, u.Email,
    (SELECT COUNT(*) FROM Vocabularies v WHERE v.UserId = u.Id) AS TotalVocabulary,
    (SELECT COUNT(*) FROM GrammarChecks gc WHERE gc.UserId = u.Id) AS TotalGrammarChecks,
    COALESCE(s.CurrentStreak, 0) AS CurrentStreak,
    COALESCE(s.LongestStreak, 0) AS LongestStreak
FROM "Users" u
LEFT JOIN Streaks s ON u.Id = s.UserId;